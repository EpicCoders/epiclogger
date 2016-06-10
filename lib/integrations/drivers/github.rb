### Github integration
module Integrations::Drivers
  class Github < Integrations::BaseDriver
    def self.display_name
      'Github'
    end

    def type
      :github
    end

    def auth_type
      :oauth
    end
  end
end
