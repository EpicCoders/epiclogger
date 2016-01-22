module ErrorStore::Interfaces
  class Stacktrace < ErrorStore::BaseInterface
    def self.display_name
      'Stacktrace'
    end

    def type
      :stacktrace
    end

    def sanitize_data(data, has_system_frames = nil)
      raise ErrorStore::ValidationError.new(self), "No 'frames' present" unless data[:frames]

      slim_frame_data(data)
      has_system_frames = data_has_system_frames(data) if has_system_frames.nil?

      frame_list = data[:frames].map { |f| Frame.new(@error).sanitize_data(f) }

      frame_list.each do |frame|
        if !has_system_frames
          frame._data[:in_app] = false
        elsif frame._data[:in_app].blank?
          frame._data[:in_app] = false
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
      self
    end

    def to_json
      {
        frames:            _data[:frames].map(&:to_json),
        frames_omitted:    _data[:frames_omitted],
        has_system_frames: _data[:has_system_frames]
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
      system_frames.zero?
    end

    def get_culprit_string
      default = nil
      _data[:frames].reverse_each do |frame|
        if frame[:in_app]
          return frame.get_culprit_string
        elsif default.nil?
          default = frame.get_culprit_string
        end
      end
      default
    end

    def get_hash(system_frames=true)
      frames = _data[:frames]

      # TODO(dcramer): this should apply only to JS
      # In a common case (I believe from window.onerror) we can end up with
      # a stacktrace which includes a single frame and a reference that isnt
      # valuable. It would generally point to the loading page, so it's possible
      # we could improve this check using that information.
      stack_invalid = (frames.length == 1 && frames.first[:lineno] == 1 && !frames.first[:function] && frames.first.path_url?)

      return [] if stack_invalid

      unless system_frames
        frames = frames.map { |f| f if f._data[:in_app] }.compact || frames
      end

      output = []
      frames.each do |frame|
        output.concat(frame.get_hash)
      end
      output
    end
  end
end
