module ErrorStore::Interfaces
  class Frame < ErrorStore::BaseInterface
    def self.display_name
      'Frame'
    end

    def type
      :frame
    end

    def sanitize_data(data)
      abs_path  = data[:abs_path]
      filename  = data[:filename]
      function  = data[:function]
      errmodule = data[:module]

      [:abs_path, :filename, :function, :module].each do |name|
        unless data[name].is_a?(String) || data[name].nil?
          raise ErrorStore::ValidationError.new(self), "Invalid value for '#{name}"
        end
      end

      # absolute path takes priority over filename
      # (in the end both will get set)
      unless abs_path
        abs_path = filename
        filename = nil
      end

      if !filename && abs_path
        if is_url?(abs_path)
          urlparts = URI(abs_path)
          if urlparts.path
            filename = urlparts.path
          else
            filename = abs_path
          end
        else
          filename = abs_path
        end
      end

      raise ErrorStore::ValidationError.new(self), "No 'filename' or 'function' or 'module'" unless (filename || function || errmodule)

      function = nil if function == '?'

      context_locals = data[:vars]
      context_locals = if context_locals.is_a?(Array)
                         Hash[context_locals]
                       elsif !context_locals.is_a?(Hash)
                         {}
                       end

      context_locals = trim_hash(context_locals) do |result|
        handle_nan(result)
      end
      # extra data is used purely by internal systems,
      # so we dont trim it
      extra_data = data[:data] || {}
      extra_data = Hash[extra_data] if extra_data.is_a?(Array)

      # XXX: handle lines which were sent as 'null'
      context_line = trim(data[:context_line], max_size: 256)
      if !context_line.blank?
        pre_context   = data[:pre_context] || nil
        pre_context   = pre_context.map { |c| c || '' } if pre_context
        post_context  = data[:post_context] || nil
        post_context  = post_context.map { |c| c || '' } if post_context
      else
        pre_context   = post_context = nil
      end

      self._data = {
        abs_path:      trim(abs_path, max_size: 256),
        filename:      trim(filename, max_size: 256),
        module:        trim(errmodule, max_size: 256),
        function:      trim(function, max_size: 256),
        context_line:  context_line,
        pre_context:   pre_context,
        post_context:  post_context,
        vars:          context_locals,
        data:          extra_data,
        errors:        data[:errors]
      }

      if !data[:lineno].blank?
        lineno = data[:lineno].to_i
        lineno = nil if lineno < 0
        self._data[:lineno] = lineno
      else
        self._data[:lineno] = nil
      end

      if !data[:colno].blank?
        self._data[:colno] = data[:colno].to_i
      else
        self._data[:colno] = nil
      end
      self
    end

    def get_culprit_string
      fileloc = _data[:module] || _data[:filename]
      return '' if fileloc.blank?
      "#{fileloc} in #{_data[:function] || '?'}"
    end

    #####
    # The hash of the frame varies depending on the data available.
    # Our ideal scenario is the module name in addition to the line of
    # context. However, in several scenarios we opt for other approaches due
    # to platform constraints.
    #####
    def get_hash
      output = []
      if _data[:module]
        if is_unhashable_module?
          output << '<module>'
        else
          output << _data[:module]
        end
      elsif _data[:filename] && !path_url? && !is_caused_by?
        output << remove_filename_outliers(_data[:filename])
      end

      can_use_context = if _data[:context_line].nil?
                          false
                        elsif _data[:context_line].length > 120
                          false
                        elsif path_url? && !_data[:function]
                          # the context is too risky to use here as it could be something
                          # coming from an HTML page or it could be minified/unparseable
                          # code, so lets defer to other lesser heuristics (like lineno)
                          false
                        elsif _data[:function] && is_unhashable_function?
                          true
                        else
                          true
                        end

      # XXX: hack around what appear to be non-useful lines of context
      if can_use_context
        output << _data[:context_line]
      elsif !output
        # If we were unable to achieve any context at this point
        # (likely due to a bad JavaScript error) we should just
        # bail on recording this frame
        return output
      elsif _data[:function]
        if is_unhashable_function?
          output << '<function>'
        else
          output << remove_function_outliers(_data[:function])
        end
      elsif !_data[:lineno].nil?
        output << _data[:lineno]
      end
      output
    end

    def is_unhashable_module?
      # this is Java specific
      _data[:module].include?('$$Lambda$')
    end

    def is_unhashable_function?
      # lambda$ is Java specific
      # [Anonymous is PHP specific (used for things like SQL queries and JSON data)
      _data[:function].start_with?('lambda$', '[Anonymous')
    end

    def is_caused_by?
      # dont compute hash using frames containing the 'Caused by'
      # text as it contains an exception value which may may contain dynamic
      # values (see raven-java#125)
      _data[:filename].start_with?('Caused by: ')
    end

    def path_url?
      return false unless _data[:abs_path]
      is_url?(_data[:abs_path])
    end
  end
end
