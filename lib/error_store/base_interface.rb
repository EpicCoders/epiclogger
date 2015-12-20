module ErrorStore
  class BaseInterface
    include ErrorStore::Utils
    attr_accessor :_data

    def initialize(error)
      @error = error
      @_data  = {}
    end

    def name
      self.class.display_name
    end

    def type
      self.class.type
    end

    def self.available
      # driver available if not rails test
      return !Rails.env.test?
    end

    def to_json
      # keep only values of zero and not blank
      return _data.delete_if { |k, v| v == 0 || v.blank? }
    end

    def get_hash
      return []
    end

    def compute_hashes(platform)
      result = self.get_hash()
      return [] unless result
      return [result]
    end
  end
end






