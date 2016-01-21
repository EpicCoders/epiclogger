module ErrorStore::Interfaces
  class SingleException < ErrorStore::BaseInterface
    def self.display_name
      'Single Exception'
    end

    def type
      :single_exception
    end

    def sanitize_data(data, has_system_frames = nil)
      raise ErrorStore::ValidationError.new(self), "No 'type' or 'value' present" unless data[:type] || data[:value]

      stacktrace = if data[:stacktrace] && data[:stacktrace][:frames]
                     Stacktrace.new(@error).sanitize_data(data[:stacktrace], has_system_frames)
                   end

      type = data[:type]
      value = data[:value]
      # we get the type from value if type not specified
      # TypeError: foo (no space)
      if !type && value.split(' ', 2)[0].include?(':')
        type, value = value.split(':', 2)
        value = value.strip
      end

      value = value.to_json unless value.blank? && value.is_a?(String)

      _data = {
        type:        trim(type, max_size: 128),
        value:       trim(value, max_size: 4096),
        module:      trim(data[:module], max_size: 128),
        stacktrace:  stacktrace
      }
      self
    end

    def to_json
      stacktrace = _data[:stacktrace].to_json if _data[:stacktrace]

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
