### Github integration
module Integrations::Drivers
  class Github < Integrations::BaseDriver
    def self.display_name
      'Github'
    end

    def type
      :github
    end

    def create_task(error_id)
      issue = GroupedIssue.find(error_id)
      website = @integration.integration.website
      configuration = @integration.integration.configuration
      url =  'https://api.github.com/repos/' + configuration["username"] + '/' + configuration["selected_application"] + '/issues'
      payload = { title: issue.message }.to_json
      headers = { "Authorization": "token " + configuration["token"], "Content-Type": "application/json" }
      response = RestClient.post url, payload, headers
      response = JSON.parse(response)
    end

    def applications
      config = @integration.integration.configuration
      response = RestClient.get 'https://api.github.com/users/' + config["username"] + '/repos'
      repos = []
      JSON.parse(response).each do |app|
        repos.push( { title: app["name"] } )
      end
      repos
    end

    def auth_type
      :oauth
    end
  end
end
