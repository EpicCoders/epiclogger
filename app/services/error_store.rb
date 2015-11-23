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
    
  end

  # 4. store the error after validating the error data
  def store_error
    
  end

  def get
    data = _request.query_parameters
    # decode get request data
  end

  def post
    # decode post request data
    data = _request.body.read
    # response_or_event_id = process

    # if isinstance(response_or_event_id, HttpResponse):
    #   return response_or_event_id
    # return HttpResponse(json.dumps({
    #     'id': response_or_event_id,
    # }), content_type='application/json')
  end

  private
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

  Auth = Struct.new(:client, :version, :app_secret, :app_key, :is_public) do
    def is_public?
      self.is_public || false
    end
  end
  Context = Struct.new(:agent, :version, :website_id, :website, :ip_address)

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

  class StoreError < StandardError
    attr_reader :website_id
    def initialize(error_store = nil)
      # @website_id = error_store.website_id
    end

    def message
      to_s
    end
  end

  # an exception raised if the user does not send the right credentials
  class MissingCredentials < StoreError; end
  # an exception raised if the website is missing
  class WebsiteMissing < StoreError; end
end