module ErrorStore
  class BaseInterface
    include ErrorStore::Utils
    attr_accessor :_data

    def initialize(error)
      @error = error
      @_data = {}
    end

    def name
      self.class.display_name
    end

    def type
      self.class.type
    end

    def self.available
      true
    end

    def to_json
      # keep only values of zero and not blank
      _data.delete_if { |_, v| v == 0 || v.blank? }
    end

    def get_hash
      []
    end
  end
end
