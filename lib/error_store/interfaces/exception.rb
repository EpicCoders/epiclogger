module ErrorStore::Interfaces
  class Exception < ErrorStore::BaseInterface
    # attr_accessor :values, :exc_omitted
    def display_name
      'Exception'
    end

    def type
      :exception
    end

    def sanitize_data(data)
      unless data.has_key?('values')
        data = { 'values' => [ data ] }
      end

      raise ErrorStore::ValidationError.new(self), 'No "values" present' unless data['values']

      trim_exceptions(data)
      has_system_frames = data_has_system_frames(data)
      @data['values'] = data['values'].map { |v| SingleException.new(@error).sanitize_data(v, has_system_frames) }

      if data['exc_omitted']
        raise ErrorStore::ValidationError.new(self), "Invalid value for 'exc_omitted'" unless data['exc_omitted'].length == 2
        @data['exc_omitted'] = data['exc_omitted']
      else
        @data['exc_omitted'] = nil
      end
      self
    end

    def to_json
      return {
          'values': @data['values'].map { |v| v.to_json() },
          'exc_omitted': @data['exc_omitted'],
      }
    end

    def data_has_system_frames(data)
      system_frames = 0
      app_frames = 0
      data['values'].each do |exc|
        next unless exc['stacktrace']
        frames = exc['stacktrace']['frames'] || []

        frames.each do |frame|
          # XXX(dcramer): handle PHP sending an empty array for a frame
          next unless frame.is_a?(Hash)
          if frame['in_app'] == true
            app_frames += 1
          else
            system_frames += 1
          end
        end
      end
      # if there is a mix of frame styles then we indicate that system frames
      # are present and should be represented as a split
      return (app_frames * system_frames) > 0
    end

    def trim_exceptions(data)
      values      = data['values']
      val_length  = values.length
      max_values  = ErrorStore::MAX_EXCEPTIONS

      return if val_length <= max_values

      half_max = max_values / 2
      data['exc_omitted'] = [ max_values, val_length - half_max ]

      (half_max..(val_length - half_max)).each do |n|
        values.delete(half_max)
      end
    end
  end
end