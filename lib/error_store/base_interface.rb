module ErrorStore
  class BaseInterface
    attr_accessor :_data

    def initialize(error)
      @error = error
      @_data  = {}
    end

    def name
      self.class.display_name
    end

    def type
      self.class.type
    end

    def to_json
      # keep only values of zero and not blank
      return _data.delete_if { |k, v| v == 0 || v.blank? }
    end

    def trim(value, max_size: ErrorStore::MAX_VARIABLE_SIZE, max_depth: 3, _depth: 0, _size: 0, &block)
      # Truncates a value to ```MAX_VARIABLE_SIZE```.
      # The method of truncation depends on the type of value.
      options = {
          max_depth: max_depth,
          max_size: max_size,
          _depth: _depth + 1,
      }

      return trim(value.to_s, _size: _size, max_size: max_size) if _depth > max_depth

      if value.is_a?(Hash)
        result  = {}
        _size   += 2
        value.each_with_index do |v, k|
          trim_v    = trim(v, _size: _size, **options, &block)
          result[k] = trim_v
          _size     += trim_v.encode('utf-8').length + 1
          break if _size >= max_size
        end
      end

      if value.is_a?(Array)
        result  = []
        _size   += 2
        value.each do |v|
          trim_v  = trim(v, _size: _size, **options, &block)
          result  << trim_v
          _size   += trim_v.encode('utf-8').length
          break if _size >= max_size
        end
      end

      if value.is_a?(String)
        result = value.truncate(max_size - _size)
      else
        result = value
      end
      return result unless block_given?
      return yield(result)
    end

    def trim_hash(value, max_items: ErrorStore::MAX_HASH_ITEMS, **args, &block)
      max_items -= 1
      value.keys.each_with_index do |key, index|
        value[key] = trim(value[key], **args, &block)
        value.delete(key) if index > max_items
      end
      return value
    end

    # TODO do we really need this? It's exactly like the one above. trim_hash
    def trim_pairs(iterable, max_items: ErrorStore::MAX_HASH_ITEMS, **args)
      max_items -= 1
      result = []
      iterable.each_with_index do |item, index|
        key, value = item.first
        result << { key => trim(value, **args) }
        return result if index > max_items
      end
      return result
    end

    def validate_bool(value, required = true)
      if required
        [true, false].include?(value)
      else
        [true, false, nil].include?(value)
      end
    end

    def is_url(filename)
      return filename.start_with?('file:', 'http:', 'https:')
    end

    def handle_nan(value)
      puts "doing handle #{value}"
      binding.pry
      # "Remove nan values that can't be json encoded"
      if value.is_a?(Float)
        return '<inf>' if value == Float::INFINITY
        return '<-inf>' if value == -Float::INFINITY
        return '<nan>' if value == Float::NAN
      end
      return value
    end
  end
end