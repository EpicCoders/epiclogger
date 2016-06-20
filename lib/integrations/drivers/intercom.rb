### Intercom integration
# - the integration we use to facilitate comunication in the app
# and get users to corelate
module Integrations::Drivers
  class Intercom < Integrations::BaseDriver
    def self.display_name
      'Intercom'
    end

    def type
      :intercom
    end

    def list_subscribers
      url = api_url + 'users'
      users = []
      response = self.get_request(url)
      response = JSON.parse(response)
      response['users'].each do |user|
        users.push( { email: user['email'], avatar: user['avatar']['image_url'] } )
      end
      users
    end

    def send_message(users = [], message)
      url = api_url + 'messages'
      responses = []
      users.each do |user|
        data = {
                    "message_type" => "inapp",
                    "body" => message,
                    "template" => "plain",
                    "from" => {
                      "type" => "admin",
                      "id" => self.configuration["uid"]
                    },
                    "to" => {
                      "type" => "user",
                      "email" => user['email']
                    }
                  }
        resource = self.post_request(url, data)
        responses.push(JSON.parse(resource.body))
      end
      responses
    end

    def header
      auth = 'Basic ' + Base64.strict_encode64( "#{self.configuration['token']}:" ).chomp
      { "Authorization": auth , "Content-Type": "application/json", "Accept": "application/json" }
    end

    def api_url
      'https://api.intercom.io/'
    end

    def auth_type
      :oauth
    end
  end
end
