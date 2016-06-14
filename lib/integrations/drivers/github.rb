### Github integration
module Integrations::Drivers
  class Github < Integrations::BaseDriver
    def self.display_name
      'Github'
    end

    def type
      :github
    end

    def applications
      config = eval @integration.integration.configuration
      response = RestClient.get 'https://api.github.com/users/' + config[:username] + '/repos'
      JSON.parse(response)
    end

    def auth_type
      :oauth
    end
  end
end
