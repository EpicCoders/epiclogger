module ErrorStore
  class Error
    attr_accessor :request, :context
    def initialize(request)
      @request = request

      # let's set the context that we are working on right now.
      @context = Context.new(self)
    end

    def create!
      get_website
      validate_data
      store_error
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
        context.website = Website.find_by(app_key: _auth.app_key)
      rescue ActiveRecord::RecordNotFound
        raise ErrorStore::WebsiteMissing.new(self), 'The website for this api key does not exist or api key wrong.'
      end

      # we also check if the website app_secret is different than the app_secret sent
      unless request.get?
        raise ErrorStore::MissingCredentials.new(self), 'Invalid api key' if @context.website.app_secret != _auth.app_secret
      end
    end

   # 3. read the body or url error data and validate it
    def validate_data
      # 1. TODO add blacklist ip option !!
      # 2. TODO add rate limit for the api option
      data = get_data

      data['project']  = context.website.id
      data['errors']   = []
      data['message']  = '<no message>' unless data.has_key?('message')
      data['event_id'] = SecureRandom.hex() unless data.has_key?('event_id')

      if data['event_id'].length > 32
        data['errors'] << { 'type' => 'value_too_long', 'name' => 'event_id', 'value' => data['event_id'] }
        data['event_id'] = SecureRandom.hex()
      end

      if data.include?('timestamp')
        begin
          process_timestamp(data)
        rescue ErrorStore::InvalidTimestamp => e
          data['errors'] << { type: 'invalid_data', 'name' => 'timestamp', 'value' => data['timestamp'] }
        end
      end

      if data.include?('fingerprint')
        begin
          process_fingerprint(data)
        rescue ErrorStore::InvalidFingerprint => e
          data['errors'] << { type: 'invalid_data', 'name' => 'fingerprint', 'value' => data['fingerprint'] }
        end
      end

      data['platform'] = 'other' if !data.include?('platform') || !VALID_PLATFORMS.include?(data['platform'])

      if data['modules'] && !data['modules'].is_a?(Array)
        data['errors'] << { 'type' => 'invalid_data', 'name': 'modules', 'value': data['modules'] }
        data.delete('modules')
      end

      if !data['extra'].blank? and !data['extra'].is_a?(Array)
        data['errors'] << { 'type' => 'invalid_data', 'name': 'extra', 'value': data['extra'] }
        data.delete('extra')
      end
      # TODO go ahead from https://github.com/getsentry/sentry/blob/master/src/sentry/coreapi.py#L489
      data.keys.each do |key|
        next if CLIENT_RESERVED_ATTRS.include?(key)

        value = data.delete(key)

        next if value.blank?

        begin
          interface = get_interface(key)
        rescue ErrorStore::InvalidAttribute => e
          data['errors'] << { type: 'invalid_attribute', 'name': key }
        end
      end
    end

    # 4. store the error after validating the error data
    def store_error
    end

    def _params
      @params ||= request.parameters
    end

    def _auth
      @auth
    end

    def get_interface(name)
      # unless 

      #   raise ErrorStore::InvalidAttribute.new(self), "Invalid interface name: #{name}"
      # end


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
      fingerprint = data['fingerprint']
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
      timestamp = data['timestamp']
      if !timestamp
        data.delete('timestamp')
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

      data['timestamp'] = timestamp.strftime('%s').to_i
      return data
    rescue Exception => e
      raise ErrorStore::InvalidTimestamp.new(self), 'We could not process timestamp'
    end

    def is_numeric?(nr_string)
       nr_string.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
    end

    def decode_json(data)
      JSON.parse(data)
    rescue Exception => e
      raise ErrorStore::BadData.new(self), 'We could not decompress your request'
    end

    def decode_and_decompress(data)
      begin
        Zlib::Inflate.inflate(Base64.decode64(data))
      rescue Zlib::Error
        Base64.decode64(data)
      end
    rescue Exception => e
      raise ErrorStore::BadData.new(self), 'We could not decompress your request'
    end

    def decompress_deflate(data)
      Zlib::Inflate.inflate(data)
    rescue Exception => e
      raise ErrorStore::BadData.new(self), 'We could not decompress your request'
    end

    def decompress_gzip(data)
      gz = Zlib::GzipReader.new(StringIO.new(data))
      gz.read
    rescue Exception => e
      raise ErrorStore::BadData.new(self), 'We could not decompress your request'
    end

    def get_origin
      return request.headers['HTTP_ORIGIN'] || request.headers['HTTP_REFERER']
    end
  end
end
