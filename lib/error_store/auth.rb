module ErrorStore
  class Auth
    attr_accessor :client, :version, :app_secret, :app_key, :public
    def initialize(error)
      @error = error
      get_authorization
    end

    # 1. get website_id from header or params if it's a get
    def get_authorization
      auth_req = if sentry_header && sentry_header.downcase.include?('sentry')
                   parse_auth_header(sentry_header)
                 elsif auth_header && auth_header.downcase.include?('sentry')
                   parse_auth_header(auth_header)
                 else
                   _error.request.params.select { |k| k.start_with?('sentry_') }
                 end

      raise ErrorStore::MissingCredentials.new(self), 'Missing authentication information' if auth_req.blank?
      # we set the client as the agent if we don't receive it
      auth_req['sentry_client'] = _error.request.headers['HTTP_USER_AGENT'] unless auth_req['sentry_client']

      @client     = auth_req['sentry_client']
      @version    = auth_req['sentry_version'] || ErrorStore::CURRENT_VERSION
      @app_secret = auth_req['sentry_secret']
      @app_key    = auth_req['sentry_key']
      @public     = _error._context.origin.present?
    end

    def parse_auth_header(header)
      Hash[header.split(' ', 2)[1].split(',').map { |x| x.strip.split('=') }]
    end

    def _error
      @error
    end

    private

    def sentry_header
      _error.request.headers['HTTP_X_SENTRY_AUTH']
    end

    def auth_header
      _error.request.headers['HTTP_AUTHORIZATION']
    end
  end
end
