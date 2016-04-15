module Integrations
  class Integration
    attr_accessor :config

    def initialize(integration, driver)
      @integration = integration
      @driver = driver.new(self)
    end

  end
end
