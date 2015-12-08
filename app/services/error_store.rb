class ErrorStore

  def initialize(request)
    @request = request
    # let's set the context that we are working on right now.
    @context = Context.new(agent: _request.headers['HTTP_USER_AGENT'], website_id: _params['id'], ip_address: _request.headers['REMOTE_ADDR'])
  end

  # 1. get website_id from header or params if it's a get
  # 2. get the website and check if it exists either by checking via api key or id
  def get_website
    # here we call the get_website_authorization method to check the get params
    # and the header params to make sure we get all the api keys and ids that are sent
    # CALL STEP 1
    @auth = get_website_authorization
    # origin =  get_origin

    raise ErrorStore::MissingCredentials.new(self), 'Missing api key' unless _auth.app_key

    # if the request is not get then we expect the app_secret to be present
    # we make the check here because we don't want to make a db request if
    # it's a post request and the app_secret is empty
    if _auth.app_secret.blank? and !_request.get?
      raise ErrorStore::MissingCredentials.new(self), 'Missing required api secret'
    end

    begin
      # let's get the website now by app_key
      _context.website = Website.find_by(app_key: _auth.app_key)
    rescue ActiveRecord::RecordNotFound
      raise ErrorStore::WebsiteMissing.new(self), 'The website for this api key does not exist or api key wrong.'
    end

    # we also check if the website app_secret is different than the app_secret sent
    unless _request.get?
      raise ErrorStore::MissingCredentials.new(self), 'Invalid api key' if website.app_secret != _auth.app_secret
    end
  end

  # 3. read the body or url error data and validate it
  def validate_data
    # 1. TODO add blacklist ip option !!
    # 2. TODO add rate limit for the api option
    data = get_data

    data['project']  = _context.website.id
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

  private
  
  Auth = Struct.new(:client, :version, :app_secret, :app_key, :is_public) do
    def is_public?
      self.is_public || false
    end
  end
  Context = Struct.new(:agent, :version, :website_id, :website, :ip_address)

  def _request
    @request
  end

  def _params
    @params ||= _request.parameters
  end

  def _auth
    @auth
  end

  def _context
    @context
  end

  def get_interface(name)
    unless 

      raise ErrorStore::InvalidAttribute.new(self), "Invalid interface name: #{name}"
    end


  end

  # get the data sent via the request
  def get_data
    if _request.get?
      data = _request.query_parameters['sentry_data']
    elsif _request.post?
      data = _request.body.read
    end
    # let's check and see if we have the content encoding defined in headers
    content_encoding = _request.headers['HTTP_CONTENT_ENCODING']

    if content_encoding == 'gzip'
      data = decompress_gzip(data)
    elsif content_encoding == 'deflate'
      data = decompress_deflate(data)
    elsif !data.start_with?('{')
      data = decode_and_decompress(data)
    end
    data = safely_load_json_string(data)

    return data
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
    data.to_json
  rescue Exception => e
    raise ErrorStore::BadData.new(self), 'We could not decompress your request'
  end

  def decode_and_decompress(data)
    begin
      Zlib::Inflate.inflate(data)
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

  # 1. get website_id from header or params if it's a get
  def get_website_authorization
    if _request.headers['HTTP_X_SENTRY_AUTH'].include?('Sentry')
      auth_req = parse_auth_header(_request.headers['HTTP_X_SENTRY_AUTH'])
    elsif _request.headers['HTTP_AUTHORIZATION'].include?('Sentry')
      auth_req = parse_auth_header(_request.headers['HTTP_AUTHORIZATION'])
    else
      # implement the get method for getting app_key
      # auth_req =
    end

    # we set the client as the agent if we don't receive it
    auth_req['sentry_client'] = _request.headers['HTTP_USER_AGENT'] unless auth_req['sentry_client']

    Auth.new(client: auth_req["sentry_client"], version: auth_req["sentry_version"], app_secret: auth_req["sentry_secret"], app_key: auth_req["sentry_key"])
  end

  def parse_auth_header(header)
    Hash[header.split(' ', 2)[1].split(',').map { |x| x.strip().split('=') }]
  end

  def get_origin
    return _request.headers['HTTP_ORIGIN'] || _request.headers['HTTP_REFERER']
  end


  # def process
  #   # check here if we have a post or a get.
  #   if _request.get?
  #     # this means that that request is sent by a client call (js client)
  #     error_params = JSON.parse(params[:sentry_data])
  #   elsif _request.post?
  #     # this means that thet request is sent by a server call
  #     data = Zlib::Inflate.inflate(Base64.decode64(_request.body.read))
  #     error_params = JSON.parse(data)
  #   end
  #   binding.pry
  #   # TODO return the error data after it was decoded and validated
  # end

end