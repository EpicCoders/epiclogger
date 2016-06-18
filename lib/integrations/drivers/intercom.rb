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

    def applications
      config = @integration.integration.configuration
      companies = []
      resource = RestClient::Resource.new('https://api.intercom.io/companies', config['token'], nil)
      response = resource.get( :content_type => :json, :accept => :json)
      response = JSON.parse(response)
      response["companies"].each do |company|
        companies.push( { title: company["name"], id: company["id"] } )
      end
      companies
    end

    def auth_type
      :oauth
    end
  end
end
