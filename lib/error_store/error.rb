module ErrorStore
  class Error
    include ErrorStore::Utils
    attr_accessor :request, :context, :data, :auth

    def initialize(request: nil, issue: nil)
      @request = request
      @issue   = issue
    end

    def self.find
      # TODO here we would set up the error with all the details so we can call specific methods
      # @data = normalize(error[:data]) || {}
      # @interface = get_interface()
    end

    def create!
      # let's set the context that we are working on right now.
      @context = Context.new(self)
      get_website
      # 1. TODO add blacklist ip option !!
      # 2. TODO add rate limit for the api option
      @data = validate_data

      event_id = @data[:event_id]
      cache_key = "issue:#{_website.id}:#{event_id}"

      # TODO filter sensitive data like passwords. Eventually add the option to manually define these.
      # TODO filter data to not have the ip defined by user
      # STEP 2:
      # Rails.cache.write(cache_key, @data)
      # ErrorWorker.perform_async(cache_key)
      ErrorStore::Error.store_error(@data)
      return event_id
    end

    # 1. get website_id from header or params if it's a get
    # 2. get the website and check if it exists either by checking via api key or id
    def get_website
      # here we call the get_website_authorization method to check the get params
      # and the header params to make sure we get all the api keys and ids that are sent
      # CALL STEP 1
      @auth = Auth.new(self)
      # origin =  get_origin

      raise ErrorStore::MissingCredentials.new(self), 'Missing api key' unless _auth.app_key

      # if the request is not get then we expect the app_secret to be present
      # we make the check here because we don't want to make a db request if
      # it's a post request and the app_secret is empty
      if _auth.app_secret.blank? and !request.get?
        raise ErrorStore::MissingCredentials.new(self), 'Missing required api secret'
      end

      begin
        # let's get the website now by app_key
        @context.website = Website.find_by(app_key: _auth.app_key)
      rescue ActiveRecord::RecordNotFound
        raise ErrorStore::WebsiteMissing.new(self), 'The website for this api key does not exist or api key wrong.'
      end

      # we also check if the website app_secret is different than the app_secret sent
      unless request.get?
        raise ErrorStore::MissingCredentials.new(self), 'Invalid api key' if _website.app_secret != _auth.app_secret
      end
    end

   # 3. read the body or url error data and validate it
    def validate_data
      # parse the data from the request and get it
      data = get_data

      # let's do a cleanup of the keys that are not reserved to client attributes
      data.keys.each { |key|  }

      # initialize some of the data attributes that are needed before we save it
      data[:website]      = _website.id
      data[:errors]       = []
      data[:interfaces]   = {}
      data[:time_spent]   = data.fetch(:time_spent, nil)
      data[:time_spent]   = data[:time_spent].to_i unless data[:time_spent].blank?
      data[:server_name]  = data.fetch(:server_name, nil)
      data[:site]         = data.fetch(:site, nil)
      data[:checksum]     = data.fetch(:checksum, nil)
      data[:environment]  = data.fetch(:environment, nil)
      data[:extra]        = data.fetch(:extra, {})

      # check if we have a message defined in our data
      if data.has_key?(:message)
        data[:message] = trim(data[:message], max_size: MAX_MESSAGE_LENGTH) unless data[:message].blank?
      else
        data[:message] = '<no message>'
      end

      # check cluprit and if we have any trim it
      if data.has_key?(:culprit)
        data[:culprit] = trim(data[:culprit], max_size: MAX_CULPRIT_LENGTH) unless data[:culprit].blank?
      else
        data[:culprit] = nil
      end

      # define an event id to be saved.
      unless data.has_key?(:event_id)
        data[:event_id] = SecureRandom.hex()
      else
        if data[:event_id].length > 32
          Rails.logger.error("Event id value is longer than 32 chars #{data[:event_id]}")
          data[:errors] << { type: 'value_too_long', name: 'event_id', value: data[:event_id] }
          data[:event_id] = SecureRandom.hex()
        end
      end

      # process timestamp data
      if data.include?(:timestamp)
        begin
          process_timestamp(data)
        rescue ErrorStore::InvalidTimestamp => e
          Rails.logger.error("Timestamp had an issue while processing  #{e.message}")
          data[:errors] << { type: 'invalid_data', name: 'timestamp', value: data[:timestamp] }
        end
      else
        data[:timestamp] = Time.now.utc
      end

      if data.include?(:fingerprint)
        begin
          process_fingerprint(data)
        rescue ErrorStore::InvalidFingerprint => e
          Rails.logger.error("Invalid fingerprint with error #{e.message}")
          data[:errors] << { type: 'invalid_data', name: 'fingerprint', value: data[:fingerprint] }
        end
      else
        data[:fingerprint] = nil
      end

      if data.has_key?(:platform)
        unless VALID_PLATFORMS.include?(data[:platform])
          data[:platform] = 'other'
        else
          data[:platform] = trim(data[:platform], max_size: 64)
        end
      else
        data[:platform] = nil
      end

      if data[:modules] && !data[:modules].is_a?(Hash)
        Rails.logger.error("Invalid modules #{data[:modules]}")
        data[:errors] << { type: 'invalid_data', name: 'modules', value: data[:modules] }
        data.delete(:modules)
      end

      if !data[:extra].blank? and !data[:extra].is_a?(Hash)
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

        if !value.is_a?(Hash)
          if value.is_a?(Array)
            value = {values: value}
          else
            Rails.logger.error("Invalid value data #{key}:#{value}")
            data[:errors] << { type: 'invalid_data', name: key, value: value }
            next
          end
        end

        begin
          interface.sanitize_data(value)
          data[:interfaces][interface.type()] = interface.to_json()
        rescue Exception => e
          Rails.logger.error("Invalid interface processing #{key}:#{value} with error #{e.message}")
          data[:errors] << { type: 'invalid_data', name: key, value: value }
        end
      end

      # set the error level
      level = data[:level] || DEFAULT_LOG_LEVEL
      if is_numeric?(level)
        begin
          data[:level] = LOG_LEVELS[level]
        rescue Exception => e
          data[:errors] << { type: 'invalid_data', name: 'level', value: level }
          data[:level] = DEFAULT_LOG_LEVEL
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

      return data
    end

    def generate_culprit(data)
      culprit = ''

      begin
        stacktraces = data[:interfaces][:exception][:values].map { |e| e[:stacktrace] if e.has_key?(:stacktrace) }.compact
      rescue Exception => e
        if data[:interfaces].has_key?(:stacktrace)
          stacktraces = [data[:interfaces][:stacktrace]]
        else
          stacktraces = nil
        end
      end

      if stacktraces.nil?
        culprit = data[:interfaces][:http].fetch(:url, '') if data[:interfaces].has_key?(:http)
      else
        culprit = ErrorStore::Interfaces::Stacktrace.new(self).sanitize_data(stacktraces[-1]).get_culprit_string()
      end

      return truncate(culprit, ErrorStore::MAX_CULPRIT_LENGTH)
    end

    # 4. store the error after validating the error data
    def self.store_error(data)
      # binding.pry
      website_id = data.delete(:website)
      website = Website.find(website_id)

      data = data.clone

      # First we pull out our top-level (non-data attr)
      event_id      = data.delete(:event_id)
      message       = data.delete(:message)
      level         = data.delete(:level)

      culprit       = data.delete(:culprit) || nil
      time_spent    = data.delete(:time_spent) || nil
      logger_name   = data.delete(:logger) || nil
      server_name   = data.delete(:server_name) || nil
      site          = data.delete(:site) || nil
      checksum      = data.delete(:checksum) || nil
      fingerprint   = data.delete(:fingerprint) || nil
      platform      = data.delete(:platform) || nil
      release       = data.delete(:release) || nil
      environment   = data.delete(:environment) || nil

      culprit = generate_culprit(data) if culprit.blank?

      # TODO here the timestamp
      # date = datetime.fromtimestamp(data.pop('timestamp'))
      # date = date.replace(tzinfo=timezone.utc)
      date = data.delete(:timestamp) # ?? not done TODO fix

      issue = Issue.new({
          website: website,
          event_id: event_id,
          data: data,
          time_spent: time_spent,
          datetime: date,
          message: message,
          platform: platform
      })

      issue_user = self._get_subscriber(website, data)

      data[:fingerprint] = fingerprint || ['{{ default }}']
      binding.pry

    end


    ## ErrorWorker
    # will be called when saving errors
    # Saves an issue to the database.
    class ErrorWorker
      include Sidekiq::Worker

      def perform(cache_key)
        # STEP 3:
        data = Rails.cache.read(cache_key)
        if data.blank?
          logger.error("Data is not available for #{cache_key} in ErrorWorker.perform")
          return
        end

        # STEP 4:
        begin
          ErrorStore::Error.store_error(data)
        ensure
          Rails.cache.delete(cache_key)
        end
      end
    end

    def _params
      @params ||= request.parameters
    end

    def _auth
      @auth
    end

    def _website
      @context.website
    end


    def self._get_subscriber(website, data)
      user_data = data[:interfaces][:user]
      return if user_data.blank?

      subscriber = Subscriber.new({
          website: website,
          identity: user_data[:id],
          email: user_data[:email],
          username: user_data[:username],
          ip_address: user_data[:ip_address]
      })
      # Serialization Failure handling
      retried = false

      begin
        Subscriber.transaction(isolation: :serializable) do
          subscriber.save()
        end
      rescue PG::TRSerializationFailure => exception
        if !retried
          retried = true
          retry
        else
          Rails.logger.info("Exception in Error._get_subscriber")
          Rails.logger.info("Message: #{exception.message}")
          Rails.logger.info("Class: #{exception.class}")
          # raise exception
        end
      rescue => exception
        Rails.logger.info("Exception in Error._get_subscriber")
        Rails.logger.info("Message: #{exception.message}")
        Rails.logger.info("Class: #{exception.class}")
        # raise exception
      end

      return subscriber
    end

    # get the data sent via the request
    def get_data
      if request.get?
        raw_data = request.query_parameters['sentry_data']
      elsif request.post?
        raw_data = request.body.read
      end
      # let's check and see if we have the content encoding defined in headers
      content_encoding = request.headers['HTTP_CONTENT_ENCODING']

      if content_encoding == 'gzip'
        data = decompress_gzip(raw_data)
      elsif content_encoding == 'deflate'
        data = decompress_deflate(raw_data)
      elsif !raw_data.start_with?('{')
        data = decode_and_decompress(raw_data)
      else
        data = raw_data
      end

      return decode_json(data)
    end

    def process_fingerprint(data)
      fingerprint = data[:fingerprint]
      raise ErrorStore::InvalidFingerprint.new(self), 'Could not process fingerprint' unless fingerprint.is_a? Array

      result = []
      fingerprint.each do |section|
        if !is_numeric?(section) || !section.is_a?(String)
          raise ErrorStore::InvalidFingerprint.new(self), 'Could not process fingerprint !(string, float, int)'
        end
        result << section
      end
      return result
    end

    def process_timestamp(data)
      # if timestamp.is_a?(DateTime)
      #   # convert time to utc
      #   if settings.TIME_ZONE:
      #     if not timezone.is_aware(timestamp):
      #       timestamp = timestamp.replace(tzinfo=timezone.utc)
      #   elif timezone.is_aware(timestamp):
      #       timestamp = timestamp.replace(tzinfo=None)
      #   timestamp = float(timestamp.strftime('%s'))
      # end


      timestamp = data[:timestamp]
      if !timestamp
        data.delete(:timestamp)
        return data
      elsif is_numeric? timestamp
        timestamp = Time.at(timestamp.to_i).to_datetime
      elsif !timestamp.is_a?(DateTime)
        timestamp = timestamp.chomp('Z') if timestamp.end_with?('Z')
        timestamp = DateTime.strptime(value, '%Y-%m-%dT%H:%M:%S')
      end

      today = DateTime.now()
      if timestamp > today + 1.minute
        raise ErrorStore::InvalidTimestamp.new(self), 'We could not process timestamp is in the future'
      end

      if timestamp < today - 30.days
        raise ErrorStore::InvalidTimestamp.new(self), 'We could not process timestamp is too old'
      end

      data[:timestamp] = timestamp.strftime('%s').to_i
      return data
    rescue Exception => e
      raise ErrorStore::InvalidTimestamp.new(self), 'We could not process timestamp'
    end

    def get_origin
      return request.headers['HTTP_ORIGIN'] || request.headers['HTTP_REFERER']
    end
  end
end
