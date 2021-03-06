module ErrorStore
  class Error
    include ErrorStore::Utils
    attr_accessor :request, :context, :data, :auth, :issue

    def initialize(request: nil, issue: nil)
      @request = request
      @issue   = issue
    end

    def find
      # TODO, here we would set up the error with all the details so we can call specific methods
      # @data = normalize(error[:data]) || {}
      # @interface = get_interface()
      @data = decode_json(@issue.data)
      self
    end

    def create!
      # let's set the context that we are working on right now.
      assign_website
      check_origin
      # 1. TODO add blacklist ip option !!
      # 2. TODO add rate limit for the api option
      @data = validate_data

      event_id = @data[:event_id]
      cache_key = "issue:#{_website.id}:#{event_id}"

      # TODO, filter sensitive data like passwords. Eventually add the option to manually define these.
      # TODO, filter data to not have the ip defined by user
      # STEP 2:
      Rails.cache.write(cache_key, @data)
      ErrorWorker.perform_async(cache_key)
      # ErrorStore::Manager.new(@data, version: @data[:version]).store_error
      event_id
    end

    def check_origin
      if _context.origin.blank?
        if request.get?
          raise ErrorStore::MissingCredentials.new(self), 'Missing required Origin or Referer header'
        end

        if request.post? && _website.app_secret != _auth.app_secret
          raise ErrorStore::MissingCredentials.new(self), 'Invalid api key'
        end
      else
        # This check is specific for clients who need CORS support
        raise ErrorStore::WebsiteMissing.new(self), 'Client must be upgraded for CORS support' if _website.nil?
        raise ErrorStore::InvalidOrigin.new(self), "Invalid origin: #{_context.origin}" unless _website.valid_origin?(_context.origin)
      end
    end

    # 1. get website_id from header or params if it's a get
    # 2. get the website and check if it exists either by checking via api key or id
    def assign_website
      # check the get params
      # and the header params to make sure we get all the api keys and ids that are sent
      # CALL STEP 1
      raise ErrorStore::MissingCredentials.new(self), 'Missing api key' unless _auth.app_key

      begin
        # let's get the website now by app_key
        _context.website = Website.find_by!(app_key: _auth.app_key)
      rescue ActiveRecord::RecordNotFound
        raise ErrorStore::WebsiteMissing.new(self), 'The website for this api key does not exist or api key wrong.'
      end

      unless ActiveSupport::SecurityUtils.secure_compare(_website.app_secret, _auth.app_secret || _website.app_secret)
        raise ErrorStore::MissingCredentials.new(self), 'Missing api key'
      end
    end

    # 3. read the body or url error data and validate it
    def validate_data
      # parse the data from the request and get it
      data = get_data

      # initialize some of the data attributes that are needed before we save it
      data[:website]      = _website.id
      data[:errors]       = []
      data[:interfaces]   = {}
      data[:time_spent]   = data.fetch(:time_spent, nil)
      data[:time_spent]   = data[:time_spent].to_i unless data[:time_spent].blank?
      data[:server_name]  = data.fetch(:server_name, nil)
      data[:site]         = data.fetch(:site, nil)
      data[:checksum]     = data.fetch(:checksum, nil)
      data[:environment]  = data.fetch(:environment, nil) || data[:tags].fetch(:environment, nil) if data[:tags].present?
      data[:extra]        = data.fetch(:extra, {})
      data.delete(:project) # remove the project attribute from data as it's not used

      # check if we have a message defined in our data
      if data.key?(:message)
        data[:message] = trim(data[:message], max_size: MAX_MESSAGE_LENGTH) unless data[:message].blank?
      else
        data[:message] = nil
      end

      # check cluprit and if we have any trim it
      if data.key?(:culprit)
        data[:culprit] = trim(data[:culprit], max_size: MAX_CULPRIT_LENGTH) unless data[:culprit].blank?
      else
        data[:culprit] = nil
      end

      # define an event id to be saved.
      if data.key?(:event_id)
        if data[:event_id].length > 32
          Rails.logger.error("Event id value is longer than 32 chars #{data[:event_id]}")
          data[:errors] << { type: 'value_too_long', name: 'event_id', value: data[:event_id] }
          data[:event_id] = SecureRandom.hex
        end
      else
        data[:event_id] = SecureRandom.hex
      end

      # process timestamp data
      begin
        data[:timestamp] = process_timestamp!(data[:timestamp])
      rescue ErrorStore::InvalidTimestamp => e
        Rails.logger.error("Timestamp had an issue while processing #{e.message}")
        data[:errors] << { type: 'invalid_data', name: 'timestamp', value: data[:timestamp] }
        data[:timestamp] = Time.zone.now.to_i
      end

      if data.include?(:fingerprint)
        begin
          process_fingerprint(data)
        rescue ErrorStore::InvalidFingerprint => e
          Rails.logger.error("Invalid fingerprint with error #{e.message}")
          data[:errors] << { type: 'invalid_data', name: 'fingerprint', value: data[:fingerprint] }
          data.delete(:fingerprint)
        end
      end

      if data.key?(:platform)
        data[:platform] = if VALID_PLATFORMS.include?(data[:platform])
                            trim(data[:platform], max_size: 64)
                          else
                            'other'
                          end
      else
        data[:platform] = nil
      end

      if data[:modules] && !data[:modules].is_a?(Hash)
        Rails.logger.error("Invalid modules #{data[:modules]}")
        data[:errors] << { type: 'invalid_data', name: 'modules', value: data[:modules] }
        data.delete(:modules)
      end

      if !data[:extra].blank? && !data[:extra].is_a?(Hash)
        Rails.logger.error("Invalid extra #{data[:extra]}")
        data[:errors] << { type: 'invalid_data', name: 'extra', value: data[:extra] }
        data.delete(:extra)
      else
        trim_hash(data[:extra], max_size: ErrorStore::MAX_VARIABLE_SIZE)
      end

      # here we check all the attributes and we run interface parsing over the ones
      # that are not reserved for the client
      # this should create json/hash values for the exception/http etc.
      data.keys.each do |key|
        next if CLIENT_RESERVED_ATTRS.include?(key)

        value = data.delete(key)
        next if value.blank?

        begin
          interface = ErrorStore.get_interface(key).new(self)
        rescue ErrorStore::InvalidInterface => e
          Rails.logger.error("Invalid interface #{e.message}")
          data[:errors] << { type: 'invalid_attribute', name: key }
        end

        unless value.is_a?(Hash)
          if value.is_a?(Array)
            value = { values: value }
          else
            Rails.logger.error("Invalid value data #{key}:#{value}")
            data[:errors] << { type: 'invalid_data', name: key, value: value }
            next
          end
        end

        begin
          interface.sanitize_data(value)
          data[:interfaces][interface.type] = interface.to_json
        rescue => e
          Rails.logger.error("Invalid interface processing #{key}:#{value} with error #{e.message}")
          data[:errors] << { type: 'invalid_data', name: key, value: value, error: e.message }
        end
      end

      # set the error level
      level = data[:level] || DEFAULT_LOG_LEVEL
      if is_numeric?(level)
        data[:level] = if LOG_LEVELS[level]
                         LOG_LEVELS[level]
                       else
                        data[:errors] << { type: 'invalid_data', name: 'level', value: level }
                        DEFAULT_LOG_LEVEL
                       end
      elsif !LOG_LEVELS.include?(data[:level])
        data[:level] = DEFAULT_LOG_LEVEL
      end

      # set the release value
      if data[:release]
        data[:release] = data[:release].encode('utf-8')
        if data[:release].length > 64
          data[:errors] << { type: 'value_too_long', name: 'release', value: data[:release] }
          data.delete(:release)
        end
      end

      data[:version] = _auth.version

      data
    end

    ## ErrorWorker
    # will be called when saving errors
    # Saves an issue to the database.
    class ErrorWorker
      include Sidekiq::Worker
      sidekiq_options :retry => 3

      def perform(cache_key)
        # STEP 3:
        data = Rails.cache.read(cache_key)
        if data.blank?
          Rails.logger.error("Data is not available for #{cache_key} in ErrorWorker.perform")
          return
        end

        # STEP 4:
        # we are calling the manager for doing the storing of error in the db
        begin
          ErrorStore::Manager.new(data).store_error
        ensure
          Rails.cache.delete(cache_key)
        end
      end
    end

    def _params
      @params ||= request.parameters
    end

    def _auth
      @auth ||= Auth.new(self)
    end

    def _context
      @context ||= Context.new(self)
    end

    def _website
      @context.website
    end

    def _get_interfaces
      result = []
      data[:interfaces].map do |key, data|
        begin
          interface = ErrorStore.get_interface(key).new(self)
        rescue ErrorStore::InvalidInterface => e
          Rails.logger.error("Invalid interface #{e.message}")
          next
        end

        value = interface.sanitize_data(data)
        next if value.blank?

        result << value
      end
      # todo return interfaces sorted by score
      result
    end

    # get the data sent via the request
    def get_data
      if request.get?
        raw_data = request.params['sentry_data']
      elsif request.post?
        raw_data = request.body.read
      end
      # let's check and see if we have the content encoding defined in headers
      content_encoding = request.headers['HTTP_CONTENT_ENCODING']

      data = if content_encoding == 'gzip'
               decompress_gzip(raw_data)
             elsif content_encoding == 'deflate'
               decompress_deflate(raw_data)
             elsif !raw_data.start_with?('{')
               decode_and_decompress(raw_data)
             else
               raw_data
             end

      decode_json(data)
    end

    def process_fingerprint(data)
      fingerprint = data[:fingerprint]
      raise ErrorStore::InvalidFingerprint.new(self), 'Could not process fingerprint' unless fingerprint.is_a?(Array)

      result = []
      fingerprint.each do |section|
        if !is_numeric?(section) || !section.is_a?(String)
          raise ErrorStore::InvalidFingerprint.new(self), 'Could not process fingerprint !(string, float, int)'
        end
        result << section
      end
      result
    end

    def get_origin
      request.headers['HTTP_ORIGIN'] || request.headers['HTTP_REFERER']
    end
  end
end
