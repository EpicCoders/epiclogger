module ErrorStore
  class Auth
    attr_accessor :client, :version, :app_secret, :app_key
    def initialize(error)
      @error = error
      get_authorization
    end

    # 1. get website_id from header or params if it's a get
    def get_authorization
      if _error.request.post?
        unless _error.request.headers.env.has_key?('HTTP_X_SENTRY_AUTH') || _error.request.headers.env.has_key?('HTTP_AUTHORIZATION')
          raise ErrorStore::MissingCredentials.new(self), 'Missing authentication header'
        end

        if _error.request.headers['HTTP_X_SENTRY_AUTH'].include?('Sentry')
          auth_req = parse_auth_header(_error.request.headers['HTTP_X_SENTRY_AUTH'])
        elsif _error.request.headers['HTTP_AUTHORIZATION'].include?('Sentry')
          auth_req = parse_auth_header(_error.request.headers['HTTP_AUTHORIZATION'])
        end
      elsif _error.request.get?
        # implement the get method for getting app_key
        # auth_req =
      end

      raise ErrorStore::MissingCredentials.new(self), 'Missing authentication information' unless auth_req
      # we set the client as the agent if we don't receive it
      auth_req['sentry_client'] = _error.request.headers['HTTP_USER_AGENT'] unless auth_req['sentry_client']

      @client     = auth_req["sentry_client"]
      @version    = auth_req["sentry_version"] || ErrorStore::CURRENT_VERSION
      @app_secret = auth_req["sentry_secret"]
      @app_key    = auth_req["sentry_key"]
    end

    def parse_auth_header(header)
      Hash[header.split(' ', 2)[1].split(',').map { |x| x.strip().split('=') }]
    end

    def _error
      @error
    end
  end
end
