module ErrorStore
  module Utils
    def is_numeric?(nr_string)
      nr_string.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/).nil? ? false : true
    end

    def decode_json(data)
      JSON.parse(data, symbolize_names: true)
    rescue
      raise ErrorStore::BadData.new(self), 'We could not decompress your request'
    end

    def decode_and_decompress(data)
      begin
        Zlib::Inflate.inflate(Base64.decode64(data))
      rescue Zlib::Error
        Base64.decode64(data)
      end
    rescue
      raise ErrorStore::BadData.new(self), 'We could not decompress your request'
    end

    def decompress_deflate(data)
      Zlib::Inflate.inflate(data)
    rescue
      raise ErrorStore::BadData.new(self), 'We could not decompress your request'
    end

    def decompress_gzip(data)
      gz = Zlib::GzipReader.new(StringIO.new(data))
      gz.read
    rescue
      raise ErrorStore::BadData.new(self), 'We could not decompress your request'
    end

    def trim(value, max_size: ErrorStore::MAX_VARIABLE_SIZE, max_depth: 3, _depth: 0, _size: 0, &block)
      # Truncates a value to ```MAX_VARIABLE_SIZE```.
      # The method of truncation depends on the type of value.
      options = {
          max_depth: max_depth,
          max_size: max_size,
          _depth: _depth + 1
      }

      return trim(value.to_s, _size: _size, max_size: max_size) if _depth > max_depth

      if value.is_a?(Hash)
        result = {}
        _size += 2
        value.each_with_index do |v, k|
          trim_v    = trim(v, _size: _size, **options, &block)
          result[k] = trim_v
          _size += trim_v.encode('utf-8').length + 1
          break if _size >= max_size
        end
      end

      if value.is_a?(Array)
        result = []
        _size += 2
        value.each do |v|
          trim_v = trim(v, _size: _size, **options, &block)
          result << trim_v
          _size += trim_v.encode('utf-8').length
          break if _size >= max_size
        end
      end

      if value.is_a?(String)
        result = value.truncate(max_size - _size)
      else
        result = value
      end
      return result unless block_given?
      yield(result)
    end

    def trim_hash(value, max_items: ErrorStore::MAX_HASH_ITEMS, **args, &block)
      max_items -= 1
      value.keys.each_with_index do |key, index|
        value[key] = trim(value[key], **args, &block)
        value.delete(key) if index > max_items
      end
      value
    end

    def trim_pairs(iterable, max_items: ErrorStore::MAX_HASH_ITEMS, **args)
      max_items -= 1
      result = []
      iterable.each_with_index do |item, index|
        key, value = item.first
        result << { key => trim(value, **args) }
        return result if index > max_items
      end
      result
    end

    def validate_bool(value, required = true)
      if required
        [true, false].include?(value)
      else
        [true, false, nil].include?(value)
      end
    end

    def is_url?(filename)
      filename.start_with?('file:', 'http:', 'https:')
    end

    def handle_nan(value)
      puts "doing handle #{value}"
      # "Remove nan values that can't be json encoded"
      if value.is_a?(Float)
        return '<inf>' if value == Float::INFINITY
        return '<-inf>' if value == -Float::INFINITY
        return '<nan>' if value == Float::NAN
      end
      value
    end

    #####
    # Remove filename build numbers. They can be version numbers or sha/md5/sha1
    #####
    def remove_filename_outliers(filename)
      filename_version_re = /(?:
        v?(?:\d+\.)*\d+|   # version numbers, v1, 1.0.0
        [a-f0-9]{7,8}|     # short sha
        [a-f0-9]{32}|      # md5
        [a-f0-9]{40}       # sha1
      )/ix
      filename.gsub(filename_version_re, '<version>')
    end

    #####
    # Remove function outliners
    # - Remove ruby random integers from erb files.
    # - Remove metadata that we don't need
    #####
    def remove_function_outliers(function)
      ruby_anon_func = /_\d{2,}/i
      return 'block' if function.start_with?('block ')
      ruby_anon_func.gsub('_<anon>', function)
    end
  end
end
