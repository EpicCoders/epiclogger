module ErrorStore::Interfaces
  class Stacktrace < ErrorStore::BaseInterface
    def self.display_name
      'Stacktrace'
    end

    def type
      :stacktrace
    end

    def sanitize_data(data, has_frames = nil)
      raise ErrorStore::ValidationError.new(self), "No 'frames' present" unless data[:frames]

      slim_frame_data(data)
      has_frames = !data[:frames].blank? if has_frames.nil?

      self._data[:frames] = data[:frames].map { |f| Frame.new(@error).sanitize_data(f) }

      if data[:frames_omitted]
        raise ErrorStore::ValidationError.new(self), "Invalid value for 'frames_omitted'" if data[:frames_omitted].length != 2
        self._data[:frames_omitted] = data[:frames_omitted]
      else
        self._data[:frames_omitted] = nil
      end

      self._data[:has_frames] = has_frames
      self
    end

    def to_json
      {
        frames:            _data[:frames].map(&:to_json),
        frames_omitted:    _data[:frames_omitted],
        has_frames:        _data[:has_frames]
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

    def get_culprit_string
      _data[:frames].last.try(:get_culprit_string)
    end

    def get_hash
      frames = _data[:frames]

      # TODO(dcramer): this should apply only to JS
      # In a common case (I believe from window.onerror) we can end up with
      # a stacktrace which includes a single frame and a reference that isnt
      # valuable. It would generally point to the loading page, so it's possible
      # we could improve this check using that information.
      stack_invalid = (frames.length == 1 && frames.first[:lineno] == 1 && !frames.first[:function] && frames.first.path_url?)

      return [] if stack_invalid

      output = []
      frames.each do |frame|
        output.concat(frame.get_hash)
      end
      output
    end
  end
end
