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
        stacktrace = Stacktrace.new(@error).sanitize_data(data[:stacktrace], has_system_frames)
      else
        stacktrace = nil
      end

      self._data = {
        type:        trim(data[:type], max_size: 128),
        value:       trim(data[:value], max_size: 4096),
        module:      trim(data[:module], max_size: 128),
        stacktrace:  stacktrace
      }
      self
    end

    def to_json
      if _data[:stacktrace]
        stacktrace = _data[:stacktrace].to_json
      else
        stacktrace = nil
      end

      {
        type:       _data[:type],
        value:      _data[:value],
        module:     _data[:module],
        stacktrace: stacktrace
      }
    end

    def get_hash
      output = nil
      if _data[:stacktrace]
        output = _data[:stacktrace].get_hash
        output << _data[:type] if output && _data[:type]
      end
      output = [_data[:type], _data[:value]].map { |e| e if e }.compact unless output
      output
    end
  end
end
