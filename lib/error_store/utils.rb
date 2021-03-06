module ErrorStore
  module Utils
    SCHEMES = %w(http https ftp ftps sftp).freeze

    def is_numeric?(nr_string)
      nr_string.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/).nil? ? false : true
    end

    def decode_json(data)
      JSON.parse(data, symbolize_names: true)
    rescue
      raise ErrorStore::BadData.new(self), 'We could not decompress your request'
    end

    def encode_and_compress(data)
      begin
        Base64.encode64(Zlib::Deflate.deflate(data))
      rescue Base64::Error
        Zlib::Deflate.deflate(data)
      end
    rescue
      raise ErrorStore::BadData.new(self), 'We could not compress your data'
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

      if _depth > max_depth
        return trim(value.to_s, _size: _size, max_size: max_size)
      elsif value.is_a?(Hash)
        result = {}
        _size += 2
        value.each do |k, v|
          trim_v    = trim(v, _size: _size, **options, &block)
          result[k] = trim_v
          _size += trim_v.to_s.length + 1
          break if _size >= max_size
        end
      elsif value.is_a?(Array)
        result = []
        _size += 2
        value.each do |v|
          trim_v = trim(v, _size: _size, **options, &block)
          result << trim_v
          _size += trim_v.to_s.length
          break if _size >= max_size
        end
      elsif value.is_a?(String)
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

    def valid_url?(url)
      parsed = Addressable::URI.parse(url) or return false
      SCHEMES.include?(parsed.scheme)
    rescue Addressable::URI::InvalidURIError
      false
    end

    def handle_nan(value)
      # "Remove nan values that can't be json encoded"
      if value.is_a?(Float)
        return '<inf>' if value.infinite? == 1
        return '<-inf>' if value.infinite? == -1
        return '<nan>' if value.nan?
      end
      value
    end

    def validate_ip(value)
      return if value.blank?

      is_valid = !!(value.to_s =~ Resolv::IPv4::Regex)
      return value if is_valid
      raise ErrorStore::BadData.new(self), 'Invalid ip' unless is_valid
    end

    def validate_email(value)
      return if value.blank?
      raise ErrorStore::BadData.new(self), 'invalid email address' unless value.to_s.include?('@')
      value
    end

    #####
    # Remove filename build numbers. They can be version numbers or sha/md5/sha1
    #####
    def remove_filename_outliers(filename)
      filename_version_re = /(?:
        v?(?:\d+\.)+\d+|   # version numbers, v1, 1.0.0
        [a-f0-9]{40}|       # sha1
        [a-f0-9]{32}|      # md5
        [a-f0-9]{7,8}     # short sha1
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
      function.gsub(ruby_anon_func, '_<anon>')
    end

    #####
    # Force UTF-8 encoding on strings
    # - checks if utf-8 is the encoding of the string
    # - fixes it if it's windows-1252
    # - replaces the invalid chars and convers to utf-8 if fail
    #####
    def fix_encoding(value)
      return unless value.is_a? String
      begin
        # Try it as UTF-8 directly
        cleaned = value.dup.force_encoding('UTF-8')
        unless cleaned.valid_encoding?
          # Some of it might be old Windows code page
          cleaned = value.encode('UTF-8', 'Windows-1252')
        end
        value = cleaned
      rescue EncodingError
        # Force it to UTF-8, throwing out invalid bits
        value.encode!('UTF-8', invalid: :replace, undef: :replace)
      end
    end

    #####
    # Force the provided time string into a timestamp
    # - checks if the provided timestapm is blank and returns today
    # - checks if the timestamp matches a numeric time or a datetime
    # - checks if the timestamp is too old or in the future and raises errors
    #####
    def process_timestamp!(timestamp)
      # This will happen everytime when coming from clients like raven-js
      if timestamp.blank?
        return Time.zone.now.to_i
      end

      begin
        if is_numeric? timestamp
          timestamp = Time.zone.at(timestamp.to_i).to_datetime
        elsif !timestamp.is_a?(DateTime)
          timestamp = timestamp.chomp('Z') if timestamp.end_with?('Z')
          timestamp = DateTime.strptime(timestamp, '%Y-%m-%dT%H:%M:%S')
        end
      rescue
        raise ErrorStore::InvalidTimestamp.new(self), "We could not process timestamp #{timestamp}"
      end

      today = Time.zone.now
      if timestamp > today + 1.minute
        raise ErrorStore::InvalidTimestamp.new(self), "We could not process timestamp is in the future #{timestamp}"
      end

      if timestamp < today - 30.days
        raise ErrorStore::InvalidTimestamp.new(self), "We could not process timestamp is too old #{timestamp}"
      end

      timestamp.strftime('%s').to_i
    end
  end
end
