module ErrorStore::Interfaces
  class SingleException < ErrorStore::BaseInterface
    def self.display_name
      'Single Exception'
    end

    def type
      :single_exception
    end

    def sanitize_data(data, has_system_frames=nil)
      raise ErrorStore::ValidationError.new(self), "No 'type' or 'value' present" unless data[:type] || data[:value]

      if data[:stacktrace] && data[:stacktrace][:frames]
        stacktrace = Stacktrace.new(@error).sanitize_data( data[:stacktrace], has_system_frames )
      else
        stacktrace = nil
      end

      self._data = {
        type:        trim(data[:type], max_size: 128),
        value:       trim(data[:value], max_size: 4096),
        module:      trim(data[:module], max_size: 128),
        stacktrace:  stacktrace,
      }
      self
    end

    def to_json
      if self._data[:stacktrace]
        stacktrace = self._data[:stacktrace].to_json()
      else
        stacktrace = nil
      end

      return {
          type:       self._data[:type],
          value:      self._data[:value],
          module:     self._data[:module],
          stacktrace: stacktrace
      }
    end

    def get_hash
      output = nil
      if self._data[:stacktrace]
        output = self._data[:stacktrace].get_hash()
        output << self._data[:type] if output and self._data[:type]
      end
      output = [self._data[:type], self._data[:value]].map { |e| e if e }.compact unless output
      return output
    end
  end
end