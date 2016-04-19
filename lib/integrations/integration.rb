module Integrations
  class Integration
    attr_accessor :config
    attr_reader :driver, :integration

    delegate :name, :type, to: :driver
    delegate :website, to: :integration

    def initialize(integration, driver)
      @integration = integration
      @driver = driver.new(self)
    end

    def connect(auth_hash)
      driver.authenticate(auth_hash)
    end
  end
end
