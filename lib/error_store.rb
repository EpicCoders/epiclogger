module ErrorStore
  INTERFACES = {
    'exception': 'Exception',
    'logentry': 'Message',
    'request': 'Http',
    'stacktrace': 'Stacktrace',
    'template': 'Template',
    'query': 'Query',
    'user': 'User',
    'csp': 'Csp',

    'sentry.interfaces.Exception': 'Exception',
    'sentry.interfaces.Message': 'Message',
    'sentry.interfaces.Stacktrace': 'Stacktrace',
    'sentry.interfaces.Template': 'Template',
    'sentry.interfaces.Query': 'Query',
    'sentry.interfaces.Http': 'Http',
    'sentry.interfaces.User': 'User',
    'sentry.interfaces.Csp': 'Csp',
  }

  CLIENT_RESERVED_ATTRS = [
    :project,
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
    :environment
  ]
  VALID_PLATFORMS = [
    'as3',
    'c',
    'cfml',
    'csharp',
    'go',
    'java',
    'javascript',
    'node',
    'objc',
    'other',
    'perl',
    'php',
    'python',
    'ruby',
  ]

  LOG_LEVELS = {
      10 => 'debug',
      20 => 'info',
      30 => 'warning',
      40 => 'error',
      50 => 'fatal',
  }

  DEFAULT_LOG_LEVEL     = 'error'
  DEFAULT_LOGGER_NAME   = ''
  MAX_STACKTRACE_FRAMES = 50
  MAX_HTTP_BODY_SIZE    = 4096 * 4  # 16kb
  MAX_EXCEPTIONS        = 25
  MAX_HASH_ITEMS        = 50
  MAX_STACKTRACE_FRAMES = 50
  MAX_VARIABLE_SIZE     = 512
  MAX_CULPRIT_LENGTH    = 200
  MAX_MESSAGE_LENGTH    = 1024 * 8
  HTTP_METHODS          = ['GET', 'POST', 'PUT', 'OPTIONS', 'HEAD', 'DELETE', 'TRACE', 'CONNECT', 'PATCH']

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