module ErrorStore
  class Context
    attr_accessor :agent, :version, :website_id, :website, :ip_address
    def initialize(agent: agent, version: version, website_id: website_id, website: website, ip_address: ip_address)
      @agent        = agent
      @version      = version
      @website_id   = website_id
      @website      = website
      @ip_address   = ip_address
    end
    # Context = Struct.new(:agent, :version, :website_id, :website, :ip_address)
  end
end
