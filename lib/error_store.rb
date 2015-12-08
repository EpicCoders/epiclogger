module ErrorStore
  SENTRY_INTERFACES = {
    'exception': 'sentry.interfaces.exception.Exception',
    'logentry': 'sentry.interfaces.message.Message',
    'request': 'sentry.interfaces.http.Http',
    'stacktrace': 'sentry.interfaces.stacktrace.Stacktrace',
    'template': 'sentry.interfaces.template.Template',
    'query': 'sentry.interfaces.query.Query',
    'user': 'sentry.interfaces.user.User',
    'csp': 'sentry.interfaces.csp.Csp',

    'sentry.interfaces.Exception': 'sentry.interfaces.exception.Exception',
    'sentry.interfaces.Message': 'sentry.interfaces.message.Message',
    'sentry.interfaces.Stacktrace': 'sentry.interfaces.stacktrace.Stacktrace',
    'sentry.interfaces.Template': 'sentry.interfaces.template.Template',
    'sentry.interfaces.Query': 'sentry.interfaces.query.Query',
    'sentry.interfaces.Http': 'sentry.interfaces.http.Http',
    'sentry.interfaces.User': 'sentry.interfaces.user.User',
    'sentry.interfaces.Csp': 'sentry.interfaces.csp.Csp',
  }

  CLIENT_RESERVED_ATTRS = [
    'project',
    'errors',
    'event_id',
    'message',
    'checksum',
    'culprit',
    'fingerprint',
    'level',
    'time_spent',
    'logger',
    'server_name',
    'site',
    'timestamp',
    'extra',
    'modules',
    'tags',
    'platform',
    'release',
    'environment'
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
end