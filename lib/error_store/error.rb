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
      @context = Context.new(self)
      get_website
      # 1. TODO add blacklist ip option !!
      # 2. TODO add rate limit for the api option
      @data = validate_data

      event_id = @data[:event_id]
      cache_key = "issue:#{_website.id}:#{event_id}"

      # TODO, filter sensitive data like passwords. Eventually add the option to manually define these.
      # TODO, filter data to not have the ip defined by user
      # STEP 2:
      # default_cache.set(cache_key, data, timeout=3600)
      # preprocess_event.delay(cache_key=cache_key, start_time=time())

      # Rails.cache.write(cache_key, @data)
      # ErrorWorker.perform_async(cache_key)
      ErrorStore::Error.store_error(@data)
      event_id
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
      if _auth.app_secret.blank? && !request.get?
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
      if data.key?(:message)
        data[:message] = trim(data[:message], max_size: MAX_MESSAGE_LENGTH) unless data[:message].blank?
      else
        data[:message] = '<no message>'
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

      if data.key?(:platform)
        if VALID_PLATFORMS.include?(data[:platform])
          data[:platform] = trim(data[:platform], max_size: 64)
        else
          data[:platform] = 'other'
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
          data[:errors] << { type: 'invalid_data', name: key, value: value }
        end
      end

      # set the error level
      level = data[:level] || DEFAULT_LOG_LEVEL
      if is_numeric?(level)
        begin
          data[:level] = LOG_LEVELS[level]
        rescue => e
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

      data
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

      # TODO, here the timestamp
      # date = datetime.fromtimestamp(data.pop('timestamp'))
      # date = date.replace(tzinfo=timezone.utc)
      date = data.delete(:timestamp) # ?? not done TODO fix

      issue = Issue.new({
          website: website,
          event_id: event_id,
          data: data.to_json,
          time_spent: time_spent,
          datetime: date,
          message: message,
          platform: platform
      })

      issue_user = _get_subscriber(website, data)

      data[:fingerprint] = fingerprint || ['{{ default }}']
      hash = md5_from_hash(get_hash_for_issue(issue))

      group_params = {
          message: message,
          platform: platform,
          culprit: culprit,
          issue_logger: logger_name,
          level: level,
          last_seen: date,
          first_seen: date,
          time_spent_total: time_spent || 0,
          time_spent_count: time_spent && 1 || 0
      }

      group, is_new, is_regression, is_sample = _save_aggregate(issue: issue, hash: hash, release: release, **group_params)

      issue.group = group
      issue.group_id = group.id

      # save the issue unless its been sampled
      # binding.pry
      # unless is_sample
        retried = false
        begin
          Issue.transaction(isolation: :serializable) do
            issue.save
          end
        rescue PG::TRSerializationFailure => exception
          if !retried
            retried = true
            retry
          else
            Rails.logger.info('Exception in Error._get_subscriber')
            Rails.logger.info("Message: #{exception.message}")
            Rails.logger.info("Class: #{exception.class}")
            raise exception
          end
        rescue => exception
          Rails.logger.info('Exception in Error._store_error')
          Rails.logger.info("Message: #{exception.message}")
          Rails.logger.info("Class: #{exception.class}")
          raise exception
        end
      # end
      issue
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
        next unless value

        result << value
      end
      # todo return interfaces sorted by score
      result
    end

    def generate_culprit(data)
      culprit = ''

      begin
        stacktraces = data[:interfaces][:exception][:values].map { |e| e[:stacktrace] if e.key?(:stacktrace) }.compact
      rescue
        if data[:interfaces].key?(:stacktrace)
          stacktraces = [data[:interfaces][:stacktrace]]
        else
          stacktraces = nil
        end
      end

      if stacktraces.nil?
        culprit = data[:interfaces][:http].fetch(:url, '') if data[:interfaces].key?(:http)
      else
        culprit = ErrorStore::Interfaces::Stacktrace.new(self).sanitize_data(stacktraces[-1]).get_culprit_string
      end

      truncate(culprit, ErrorStore::MAX_CULPRIT_LENGTH)
    end

    def self.get_hash_for_issue(issue)
      get_hash_for_issue_with_reason(issue)[1]
    end

    def self.get_hash_for_issue_with_reason(issue)
      interfaces = issue.get_interfaces
      interfaces.each do |interface|
        result = interface.compute_hashes(issue.platform)
        next unless result
        return [interface.type, result]
      end
      [:message, [issue.message]]
    end

    def self.md5_from_hash(hash_chunks)
      result = Digest::MD5.new
      hash_chunks.each do |chunk|
        result.update(chunk.to_s)
      end
      result.hexdigest
    end

    def self._handle_regression(group, issue, release)
      return unless group.is_resolved?
      # we now think its a regression, rely on the database to validate that
      # no one beat us to this
      date = [issue.datetime, group.last_seen].max
      is_regression = GroupedIssue.where(id: group.id,
                                         status: [
                                                    GroupedIssue.status.find_value(:resolved).value,
                                                    GroupedIssue.status.find_value(:unresolved).value
                                                  ]
                                        )
                                  .update_attributes(active_at: date, last_seen: date, status: :unresolved)

      group.active_at = date
      group.status = :unresolved

      is_regression
    end

    def self.count_limit(count)
      # TODO: could we do something like num_to_store = max(math.sqrt(100*count)+59, 200) ?
      # ~ 150 * ((log(n) - 1.5) ^ 2 - 0.25)
      ErrorStore::SENTRY_SAMPLE_RATES.map do |amount, sample_rate|
        return sample_rate if count <= amount
      end
      ErrorStore::SENTRY_MAX_SAMPLE_RATE
    end

    def self.time_limit(silence) # ~ 3600 per hour
      ErrorStore::SENTRY_SAMPLE_TIMES.map do |amount, sample_rate|
        return sample_rate if silence >= amount
      end
      ErrorStore::SENTRY_MAX_SAMPLE_TIME
    end

    def self.should_sample(current_datetime, last_seen, times_seen)
      silence_timedelta = current_datetime - last_seen
      silence = silence_timedelta.days * 86400 + silence_timedelta.seconds

      return false if times_seen % count_limit(times_seen) == 0
      return false if times_seen % time_limit(silence) == 0
      true
    end

    def self._process_existing_aggregate(group: group, issue: issue, data: data, release: release)
      date = [issue.datetime, group.last_seen].max
      extra = {
          last_seen: date,
          # score: ScoreClause(group),
      }
      extra[:message] = issue.message if issue.message && issue.message != group.message
      extra[:level] = data[:level] if group.level != data[:level]
      extra[:culprit] = data[:culprit] if group.culprit != data[:culprit]
      # TODO, continue here.
      is_regression = _handle_regression(group, issue, release)

      group.last_seen = extra[:last_seen]

      update_args = { times_seen: 1 }
      if issue.time_spent
        update_args[:time_spent_total] = issue.time_spent
        update_args[:time_spent_count] = 1
      end

      is_regression
    end

    # here we save the grouped issue with all details
    def self._save_aggregate(issue: issue, hash: hash, release: release, **args)
      website = issue.website
      # attempt to find a matching hash
      group = GroupedIssue.find_by(checksum: hash)
      existing_group_id = group.try(:id)

      if existing_group_id.nil?
        # args[:score]  = ScoreClause.calculate(1, args[:last_seen])
        args[:checksum] = hash
        group_is_new = true
        group = GroupedIssue.create(website: website, **args)
      else
        group_is_new = false
      end

      # XXX(dcramer): it's important this gets called **before** the aggregate
      # is processed as otherwise values like last_seen will get mutated
      can_sample = should_sample(issue.datetime, group.last_seen, group.times_seen)

      if group_is_new
        is_regression = false
      else
        is_regression = _process_existing_aggregate(
            group: group,
            issue: issue,
            data: args,
            release: release,
        )
      end

      # Determine if we've sampled enough data to store this issue
      if group_is_new || is_regression
        is_sample = false
      else
        is_sample = can_sample
      end

      return group, group_is_new, is_regression, is_sample
    end

    def self._get_subscriber(website, data)
      user_data = data[:interfaces][:user]
      return if user_data.blank?

      subscriber = Subscriber.new(
          website: website,
          identity: user_data[:id],
          email: user_data[:email],
          username: user_data[:username],
          ip_address: user_data[:ip_address]
      )
      # Serialization Failure handling
      retried = false

      begin
        Subscriber.transaction(isolation: :serializable) do
          subscriber.save
        end
      rescue PG::TRSerializationFailure => exception
        if !retried
          retried = true
          retry
        else
          Rails.logger.info('Exception in Error._get_subscriber')
          Rails.logger.info("Message: #{exception.message}")
          Rails.logger.info("Class: #{exception.class}")
          # raise exception
        end
      rescue => exception
        Rails.logger.info('Exception in Error._get_subscriber')
        Rails.logger.info("Message: #{exception.message}")
        Rails.logger.info("Class: #{exception.class}")
        # raise exception
      end

      subscriber
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
      request.headers['HTTP_ORIGIN'] || request.headers['HTTP_REFERER']
    end
  end
end
