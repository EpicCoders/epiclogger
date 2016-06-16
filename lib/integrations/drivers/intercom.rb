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
      config = eval @integration.integration.configuration
      intercom = ::Intercom::Client.new(token: config[:token])
      companies = []
      intercom.companies.all.each do |company|
        companies.push( { title: company.name, app_id: company.created_at, provider: config[:provider] } )
      end
      companies
    end

    def auth_type
      :oauth
    end
  end
end
