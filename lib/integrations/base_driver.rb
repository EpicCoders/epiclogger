module Integrations
  class BaseDriver

    def initialize(integration)
      @integration = integration
    end

    def self.available
      true
    end

    def name
      self.class.display_name
    end

    def type
      self.class.type
    end

    def authenticate(hash)
      raise Integrations::NotImplementedError.new(self), 'Authenticate not implemented'
    end
  end
end
