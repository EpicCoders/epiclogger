module ErrorStore::Interfaces
  class Http < ErrorStore::BaseInterface
    def self.display_name
      'HTTP'
    end

    def type
      :http
    end

    def sanitize_data(data, has_system_frames = nil)
      raise ErrorStore::ValidationError.new(self), "No value for 'url'" unless data[:url]

      if data[:method]
        _data[:method] = data[:method].upcase
        raise ErrorStore::ValidationError.new(self), "Invalid value for 'method'" unless ErrorStore::HTTP_METHODS.include?(method)
        _data[:method] = method
      else
        _data[:method] = nil # TODO, check this is not used
      end

      url_uri      = URI(data[:url])
      query_string = data[:query_string] || url_uri.query
      if query_string
        # if querystring was a hash, convert it to a string
        if query_string.is_a?(Hash)
          query_string = query_string.to_query
        elsif query_string[0] == '?'
          # remove '?' prefix
          query_string[0] = ''
        end
        _data[:query_string] = trim(query_string, max_size: 4096)
      else
        _data[:query_string] = ''
      end

      fragment = data[:fragment] || url_uri.fragment

      cookies = data[:cookies]
      # if cookies were [also] included in headers we
      # strip them out
      headers = data[:headers]
      if headers
        headers, cookie_header = format_headers(headers)
        cookies = cookie_header if !cookies && cookie_header
      else
        headers = []
      end
      body = data[:data]
      body = body.to_json if body.is_a?(Hash)

      body = trim(body, max_size: ErrorStore::MAX_HTTP_BODY_SIZE) if body

      _data = {
        cookies:   trim_pairs(format_cookies(cookies)),
        env:       trim_hash(data[:env] || {}),
        headers:   trim_pairs(headers),
        data:      body,
        url:       "#{url_uri.scheme}://#{url_uri.host}/#{url_uri.path}",
        fragment:  trim(fragment, max_size: 1024)
      }
      self
    end

    def format_headers(value)
      return [] if value.blank?

      result = []
      cookie_header = nil
      value.map do |k, v|
        k, v = k.first if k.is_a?(Hash)
        v = v.join(', ') if v.is_a?(Array)

        if k.downcase == 'cookie'
          cookie_header = v
        else
          result << { k.to_s.parameterize.underscore.to_sym => v }
        end
      end
      return result, cookie_header
    end

    def format_cookies(value)
      return {} if value.blank?

      value = Rack::Utils.parse_nested_query(value) if value.is_a?(String)

      value.map { |k, v| { k.encode('utf-8').strip => v } }
    end
  end
end
