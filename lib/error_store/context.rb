module ErrorStore
  class Context
    attr_accessor :agent, :website_id, :ip_address, :version, :website
    def initialize(error)
      @error        = error
      @agent        = @error.request.headers['HTTP_USER_AGENT']
      @website_id   = @error._params['id']
      @ip_address   = @error.request.headers['REMOTE_ADDR']
    end
  end
end
