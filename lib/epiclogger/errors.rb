module Epiclogger
  module Errors
    class NotAllowed < RuntimeError
      attr_accessor :status
      def initialize(status = 401)
        @status = status
      end
    end
  end
end
