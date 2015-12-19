module ErrorStore::Interfaces
  class Stacktrace < ErrorStore::BaseInterface
    def self.display_name
      'Stacktrace'
    end

    def type
      :stacktrace
    end

    def sanitize_data(data, has_system_frames=nil)
      raise ErrorStore::ValidationError.new(self), "No 'frames' present" unless data[:frames]

      slim_frame_data(data)
      has_system_frames = data_has_system_frames(data) if has_system_frames.nil?

      frame_list = data[:frames].map { |f| Frame.new(@error).sanitize_data(f) }

      frame_list.each do |frame|
        if !has_system_frames
          frame[:in_app] = false
        elsif frame[:in_app].blank?
          frame[:in_app] = false
        end
      end

      self._data[:frames] = frame_list

      if data[:frames_omitted]
        raise ErrorStore::ValidationError.new(self), "Invalid value for 'frames_omitted'" if data[:frames_omitted].length != 2
        self._data[:frames_omitted] = data[:frames_omitted]
      else
        self._data[:frames_omitted] = nil
      end

      self._data[:has_system_frames] = has_system_frames
      return self._data
    end

    def to_json
      return {
         frames:            self._data[:frames].map { |f| f.to_json() },
         frames_omitted:    self._data[:frames_omitted],
         has_system_frames: self._data[:has_system_frames],
      }
    end

    def slim_frame_data(stacktrace, frame_allowance = ErrorStore::MAX_STACKTRACE_FRAMES)
      # Removes various excess metadata from middle frames which go beyond ``frame_allowance``.
      frames = stacktrace[:frames]
      frames_len = frames.length

      return if frames_len <= frame_allowance

      half_max = frame_allowance / 2

      (half_max..(frames_len - half_max)).each do |n|
        # remove heavy components
        frames[n].delete(:vars)
        frames[n].delete(:pre_context)
        frames[n].delete(:post_context)
      end
    end

    def data_has_system_frames(data)
      system_frames = 0
      data[:frames].each do |frame|
        system_frames += 1 unless frame[:in_app]
      end

      return false if data[:frames].length == system_frames
      return system_frames.zero?
    end
  end
