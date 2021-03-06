module Integrations
  class Integration
    attr_accessor :config
    attr_reader :driver, :integration

    delegate :name, :type, :auth_type, :build_configuration, :applications, :create_task, :list_subscribers, :send_message, :selected_application, to: :driver
    delegate :website, to: :integration

    def initialize(integration, driver)
      @integration = integration
      @driver = driver.new(self)
    end
  end
end
