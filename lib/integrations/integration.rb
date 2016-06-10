module Integrations
  class Integration
    attr_accessor :config
    attr_reader :driver, :integration

    delegate :name, :type, :auth_type, :build_configuration, to: :driver
    delegate :website, to: :integration

    def initialize(integration, driver)
      @integration = integration
      @driver = driver.new(self)
    end
  end
end
