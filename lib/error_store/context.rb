module ErrorStore
  class Context
    attr_accessor :agent, :website_id, :ip_address, :version, :website
    def initialize(error)
      @error = error
      @agent        = @error.request.headers['HTTP_USER_AGENT']
      # @version      = version
      @website_id   = @error._params['id']
      # @website      = website
      @ip_address   = @error.request.headers['REMOTE_ADDR']
    end
    # Context = Struct.new(:agent, :version, :website_id, :website, :ip_address)
  end
end
