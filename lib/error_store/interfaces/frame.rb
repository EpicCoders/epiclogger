module ErrorStore::Interfaces
  class Frame < ErrorStore::BaseInterface
    # attr_accessor :abs_path, :filename, :errmodule, :function, :in_app, :context_line, :pre_context, :post_context, :vars, :data, :errors, :lineno, :colno

    def display_name
      'Frame'
    end

    def type
      :frame
    end

    def sanitize_data(data, has_system_frames=nil)
      abs_path  = data['abs_path']
      filename  = data['filename']
      function  = data['function']
      errmodule = data['module']

      ['abs_path', 'filename', 'function', 'module'].each do |name|
        unless data[name].is_a?(String) || data[name].nil?
          raise ErrorStore::ValidationError.new(self), "Invalid value for '#{name}"
        end
      end

      # absolute path takes priority over filename
      # (in the end both will get set)
      if !abs_path
        abs_path = filename
        filename = nil
      end

      if !filename && abs_path
        if is_url(abs_path)
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

      raise ErrorStore::ValidationError.new(self), "No 'filename' or 'function' or 'module'" if !(filename || function || errmodule)

      function = nil if function == '?'

      context_locals = data['vars'] || {}
      if context_locals.is_a?(Array)
        context_locals = Hash[context_locals]
      elsif !context_locals.is_a?(Hash)
        context_locals = {}
      end

      context_locals = trim_hash(context_locals) do |result|
                         handle_nan(result)
                       end
      # extra data is used purely by internal systems,
      # so we dont trim it
      extra_data = data['data'] || {}
      extra_data = Hash[extra_data] if extra_data.is_a?(Array)

      # XXX: handle lines which were sent as 'null'
      context_line = trim(data['context_line'], max_size: 256)
      if !context_line.blank?
        pre_context   = data['pre_context'] || nil
        pre_context   = pre_context.map { |c| c || '' } if pre_context
        post_context  = data['post_context'] || nil
        post_context  = post_context.map { |c| c || '' } if post_context
      else
        pre_context   = post_context = nil
      end


      in_app = validate_bool(data['in_app'], false)
      raise ErrorStore::ValidationError.new(self), "Invalid value for 'in_app'" unless in_app

      @data = {
        'abs_path'     => trim(abs_path, max_size: 256),
        'filename'     => trim(filename, max_size: 256),
        'errmodule'    => trim(errmodule, max_size: 256),
        'function'     => trim(function, max_size: 256),
        'in_app'       => in_app,
        'context_line' => context_line,
        'pre_context'  => pre_context,
        'post_context' => post_context,
        'vars'         => context_locals,
        'data'         => extra_data,
        'errors'       => data['errors'],
      }

      if !data['lineno'].blank?
        lineno = data['lineno'].to_i
        lineno = nil if lineno < 0
        @data['lineno'] = lineno
      else
        @data['lineno'] = nil
      end

      if !data['colno'].blank?
        @data['colno'] = data['colno'].to_i
      else
        @data['colno'] = nil
      end
      return @data
    end
  end
end

