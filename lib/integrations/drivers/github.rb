### Github integration
module Integrations::Drivers
  class Github < Integrations::BaseDriver
    def self.display_name
      'Github'
    end

    def type
      :github
    end

    def api_url
      'https://api.github.com/'
    end

    def create_task(title)
      url =  api_url + 'repos/' + self.configuration["application_owner"].to_s + '/' + self.configuration["selected_application"].to_s + '/issues'
      data = { title: title }
      response = post_request(url, data)
      if response
        response = JSON.parse(response)
        response
      end
    end

    def applications
      url = api_url + 'user/repos?affiliation=owner,organization_member'
      response = get_request(url)
      if response
        repos = { "Owner": [] }
        JSON.parse(response).each do |repo|
          if repo['owner']['type'] == 'Organization'
            if repos[repo['owner']['login']]
              repos[repo['owner']['login']].push(repo["name"])
            else
              repos[repo['owner']['login']] = [repo["name"]]
            end
          elsif repo['fork'] == false
            repos[:Owner].push(repo["name"])
          end
        end
        repos
      end
    end

    def header
      { "Authorization": "token #{self.configuration["token"]}", "Content-Type": "application/json", "Accept": "application/json" }
    end

    def selected_application
      self.configuration['selected_application']
    end

    def auth_type
      :oauth
    end
  end
end
