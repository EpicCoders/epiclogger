module Integrations
  class BaseDriver
    def initialize(integration)
      @integration = integration
    end

    def self.available
      true
    end

    def name
      self.class.display_name
    end

    def type
      self.class.type
    end

    def config
      Integrations.config[type]
    end

    def applications
      self.class.applications
    end

    def selected_application
      self.class.selected_application
    end

    def configuration
      @integration.integration.configuration
    end

    def build_configuration(auth_hash)
      config = {}

      auth_type = @integration.auth_type
      token = auth_hash['credentials']['token'] if auth_type == :oauth
      token.strip! if token.present?

      config[:token] = token
      if auth_type == :oauth
        config[:username]         = auth_hash['extra']['raw_info']['login']
        config[:provider]         = auth_hash['provider']
        config[:secret]           = auth_hash['credentials']['secret']
        config[:refresh_token]    = auth_hash['credentials']['refresh_token']
        config[:token_expires_at] = auth_hash['credentials']['expires_at']
        config[:token_expires]    = auth_hash['credentials']['expires']
        config[:uid]              = auth_hash['uid'] if auth_hash['uid'].present?
      end
      config
    end

    def get_request(url)
      RestClient.get url, header rescue 'Operation failed!'
    end

    def post_request(url, data)
      RestClient.post url, data.to_json, header rescue 'Operation failed!'
    end
  end
end
