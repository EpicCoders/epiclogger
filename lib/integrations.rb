module Integrations
  def self.create(integration)
    driver = get_driver(integration.provider)
    Integrations::Integration.new(integration, driver)
  end

  @@drivers_list = []

  def self.find_drivers
    Dir[Pathname(File.dirname(__FILE__)).join('integrations/drivers/*.rb')].each do |path|
      base = File.basename(path, '.rb')
      begin
        klass = driver_class(base)
        if !klass.respond_to?(:available) || klass.available
          register_driver({
              name: klass.display_name,
              type: base.to_sym,
              driver: klass
          })
        end
      rescue
        Rails.logger.error("Could not load class #{base}")
      end
    end
    @@drivers_list.sort! { |a, b| a[:name].casecmp(b[:name]) }
  end

  def self.driver_class(type)
    "Integrations::Drivers::#{type.to_s.classify}".constantize
  end

  def self.register_driver(driver)
    @@drivers_list ||= []
    @@drivers_list <<= driver
  end

  def self.available_drivers
    @@drivers_list
  end

  def self.drivers_types
    @@drivers_list.map { |i| i[:type] }
  end

  def self.get_driver(type)
    driver = available_drivers.find { |e| e[:type] == type }.try(:[], :driver)
    raise Integrations::InvalidDriver.new(self), 'This driver does not exist' if driver.nil?
    driver
  end

  class IntegrationError < StandardError
    attr_reader :website_id
    def initialize(error_integration = nil)
      # @website_id = error_store.website_id
    end

    def message
      to_s
    end
  end

  # an exception raised if the website is missing
  class WebsiteMissing < IntegrationError; end
  # an exception raised when the timestamp is not valid
  class InvalidDriver < IntegrationError; end
  class ValidationError < IntegrationError; end
end

Integrations.find_drivers
