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

    def authenticate(hash)

    end
  end
end
