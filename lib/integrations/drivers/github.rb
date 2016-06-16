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
      repos = []
      JSON.parse(response).each do |app|
        repos.push( { title: app["name"], app_id: app["id"], provider: config[:provider] }, url: app["owner"]["url"] )
      end
      repos
    end

    def auth_type
      :oauth
    end
  end
end
