module ErrorStore
  def self.create!(request)
    ErrorStore::Error.new(request: request).create!
  end

  def self.find(issue)
    ErrorStore::Error.new(issue: issue).find
  end
  @@interfaces_list = []

  def self.find_interfaces
    Dir[Pathname(File.dirname(__FILE__)).join('error_store/interfaces/*.rb')].each do |path|
      base = File.basename(path, '.rb')
      begin
        klass = interface_class(base)
        if !klass.respond_to?(:available) || klass.available
          register_interface({
              name: klass.display_name,
              type: base.to_sym,
              interface: klass
          })
        end
      rescue
        Rails.logger.error("Could not load class #{base}")
      end
    end
  end

  def self.interface_class(type)
    "ErrorStore::Interfaces::#{type.to_s.classify}".constantize
  end

  def self.register_interface(interface)
    @@interfaces_list ||= []
    @@interfaces_list <<= interface
  end

  def self.available_interfaces
    @@interfaces_list
  end

  def self.interfaces_types
    @@interfaces_list.map { |i| i[:type] }
  end

  def self.get_interface(type)
    interface_name = INTERFACES[type]
    interface = available_interfaces.find { |e| e[:type] == interface_name }.try(:[], :interface)
    raise ErrorStore::InvalidInterface.new(self), 'This interface does not exist' if interface.nil?
    interface
  end

  INTERFACES = {
    'exception': :exception,
    'logentry': :message,
    'request': :http,
    'stacktrace': :stacktrace,
    'template': :template,
    'query': :query,
    'user': :user,
    'csp': :csp,
    'http': :http,

    'sentry.interfaces.Exception': :exception,
    'sentry.interfaces.Message': :message,
    'sentry.interfaces.Stacktrace': :stacktrace,
    'sentry.interfaces.Template': :template,
    'sentry.interfaces.Query': :query,
    'sentry.interfaces.Http': :http,
    'sentry.interfaces.User': :user,
    'sentry.interfaces.Csp': :csp
  }

  CLIENT_RESERVED_ATTRS = [
    :website,
    :errors,
    :event_id,
    :message,
    :checksum,
    :culprit,
    :fingerprint,
    :level,
    :time_spent,
    :logger,
    :server_name,
    :site,
    :timestamp,
    :extra,
    :modules,
    :tags,
    :platform,
    :release,
    :environment,
    :interfaces
  ]
  VALID_PLATFORMS = %w(as3 c cfml csharp go java javascript node objc other perl php python ruby)

  LOG_LEVELS = {
      10 => 'debug',
      20 => 'info',
      30 => 'warning',
      40 => 'error',
      50 => 'fatal'
  }

  # The following values control the sampling rates
  SAMPLE_RATES = [
      # up until N events, store 1 in M
      [50, 1],
      [1000, 2],
      [10000, 10],
      [100000, 50],
      [1000000, 300],
      [10000000, 2000]
  ]
  MAX_SAMPLE_RATE = 10000
  SAMPLE_TIMES = [
      [3600, 1],
      [360, 10],
      [60, 60],
  ]
  MAX_SAMPLE_TIME = 10000

  CURRENT_VERSION       = '5'
  DEFAULT_LOG_LEVEL     = 'error'
  DEFAULT_LOGGER_NAME   = ''
  MAX_STACKTRACE_FRAMES = 50
  MAX_HTTP_BODY_SIZE    = 4096 * 4 # 16kb
  MAX_EXCEPTIONS        = 25
  MAX_HASH_ITEMS        = 50
  MAX_VARIABLE_SIZE     = 512
  MAX_CULPRIT_LENGTH    = 200
  MAX_MESSAGE_LENGTH    = 1024 * 8
  HTTP_METHODS          = %w(GET POST PUT OPTIONS HEAD DELETE TRACE CONNECT PATCH)

  class StoreError < StandardError
    attr_reader :website_id
    def initialize(error_store = nil)
      # @website_id = error_store.website_id
    end

    def message
      to_s
    end
  end

  # an exception raised if the user does not send the right credentials
  class MissingCredentials < StoreError; end
  # an exception raised if the website is missing
  class WebsiteMissing < StoreError; end
  # an exception raised of the request data is bogus
  class BadData < StoreError; end
  # an exception raised when the timestamp is not valid
  class InvalidTimestamp < StoreError; end
  class InvalidFingerprint < StoreError; end
  class InvalidAttribute < StoreError; end
  class InvalidInterface < StoreError; end
  class ValidationError < StoreError; end
end

ErrorStore.find_interfaces
