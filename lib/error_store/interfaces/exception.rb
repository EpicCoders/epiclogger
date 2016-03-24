module ErrorStore::Interfaces
  class Exception < ErrorStore::BaseInterface
    def self.display_name
      'Exception'
    end

    def type
      :exception
    end

    def sanitize_data(data)
      data = { values: [data] } unless data.key?(:values)

      raise ErrorStore::ValidationError.new(self), 'No "values" present' if data[:values].blank?

      has_frames = data_has_frames(data)
      self._data[:values] = data[:values].map { |v| SingleException.new(@error).sanitize_data(v, has_frames) }

      if data[:exc_omitted]
        raise ErrorStore::ValidationError.new(self), "Invalid value for 'exc_omitted'" unless data[:exc_omitted].length == 2
        self._data[:exc_omitted] = data[:exc_omitted]
      else
        self._data[:exc_omitted] = nil
      end
      self
    end

    def to_json
      {
        values:      _data[:values].map(&:to_json),
        exc_omitted: _data[:exc_omitted]
      }
    end

    def data_has_frames(data)
      nr_frames = 0
      data[:values].each do |exc|
        next unless exc[:stacktrace]
        frames = exc[:stacktrace][:frames] || []
        frames.each { |frame| nr_frames += 1 if frame.is_a?(Hash) }
      end
      # check if frames are 0 or not
      # true if not zero
      !nr_frames.zero?
    end

    def get_hash
      # some exceptions might have stacktraces
      # while others may not and we ALWAYS want stacktraces over values
      output = []
      _data[:values].each do |value|
        next unless value._data[:stacktrace]
        stack_hash = value._data[:stacktrace].get_hash
        if stack_hash
          output.concat(stack_hash)
          output << value.type
        end
      end

      unless output.blank?
        _data[:values].each do |value|
          output.concat(value.get_hash)
        end
      end

      output
    end
  end
end
