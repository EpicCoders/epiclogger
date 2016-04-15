module Integrations
  class Integration
    attr_accessor :config
    attr_reader :driver, :integration

    delegate :name, :type, to: :driver

    def initialize(integration, driver)
      @integration = integration
      @driver = driver.new(self)
    end
  end
end
