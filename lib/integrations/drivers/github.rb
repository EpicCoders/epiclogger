### Github integration
module Integrations::Drivers
  class Github < Integrations::BaseDriver
    def self.display_name
      'Github'
    end

    def type
      :github
    end

    def authenticate(hash)
      auth_hash = hash

      config = auth_hash

      config
    end
  end
end
