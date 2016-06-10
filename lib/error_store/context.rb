module ErrorStore
  class Context
    attr_accessor :agent, :website_id, :ip_address, :version, :website, :origin
    def initialize(error)
      @error        = error
      @agent        = @error.request.headers['HTTP_USER_AGENT']
      @website_id   = @error._params['id']
      @ip_address   = @error.request.headers['REMOTE_ADDR']
      @origin       = origin_from_request
    end

    def origin_from_request
      _error.request.headers['HTTP_ORIGIN'] || _error.request.headers['HTTP_REFERER']
    end

    private

    def _error
      @error
    end
  end
end
