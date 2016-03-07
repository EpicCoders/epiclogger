### The template interface is a single frame in stacktrace
# The attributes ``filename``, ``context_line``, and ``lineno`` are required.
module ErrorStore::Interfaces
  class Template < ErrorStore::BaseInterface
    def self.display_name
      'Template'
    end

    def type
      :template
    end

    def santize_data(data)
      if [data[:filename], data[:context_line], data[:lineno]].any?(&:blank?)
        raise ErrorStore::ValidationError.new(self), 'Please provide filename, context_line and lineno'
      end
      self._data = {
        abs_path: trim(data[:abs_path], max_size: 256),
        filename: trim(data[:filename], max_size: 256),
        context_line: trim(data[:context_line], max_size: 256),
        lineno: data[:lineno].to_i,
        pre_context: data[:pre_context],
        post_context: data[:post_context]
      }
      self
    end

    def get_hash
      [_data[:filename], _data[:context_line]]
    end
  end
end
