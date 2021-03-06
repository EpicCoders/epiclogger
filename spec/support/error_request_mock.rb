module ErrorRequestMock
  def post_error_request(data, website, client_version: '5', client: 'raven-ruby/0.15.2', encoding: 'other')
    if encoding == 'gzip'
      encoding_type = 'gzip'
      encoded_data = StringIO.new(ActiveSupport::Gzip.compress(data))
    elsif encoding == 'deflate'
      encoding_type = 'deflate'
      encoded_data = StringIO.new(Zlib::Deflate.deflate(data))
    else
      encoding_type = 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3'
      encoded_data = StringIO.new(Base64.strict_encode64(Zlib::Deflate.deflate(data)))
    end

    ActionDispatch::Request.new(
      'REQUEST_METHOD' => 'POST',
      'HTTP_USER_AGENT' => 'Faraday v0.9.2',
      'REMOTE_ADDR' => '127.0.0.1',
      'HTTP_ORIGIN' => 'http://192.168.2.3',
      'HTTP_X_SENTRY_AUTH' => "Sentry sentry_version=#{client_version}, sentry_client=#{client}, sentry_timestamp=1455616740, sentry_key=#{website.app_key}, sentry_secret=#{website.app_secret}",
      'HTTP_ACCEPT_ENCODING' => encoding_type,
      'HTTP_CONTENT_ENCODING' => encoding_type,
      'rack.input' => encoded_data
    )
  end

  def validated_request(request)
    error = ErrorStore::Error.new(request: request)
    error.context = ErrorStore::Context.new(error)
    error.auth = ErrorStore::Auth.new(error)
    error.assign_website
    error.validate_data
  end

  def get_error_request(data, website, client_version: '4', client: 'raven-js/1.1.20')
    query = {
      'sentry_version' => client_version,
      'sentry_client' => client,
      'sentry_key' => website.app_key,
      'sentry_data' => data.to_json,
      'id' => website.id
    }

    ActionDispatch::Request.new(
      'REQUEST_METHOD' => 'GET',
      'HTTP_ORIGIN' => 'http://192.168.2.3',
      'QUERY_STRING' => query.to_param,
      'rack.input' => StringIO.new('')
    )
  end

  def web_response_factory(path, json: false)
    extensions = %w(json txt xml)
    base = "#{Rails.root}/spec/factories/web_responses/#{path}"

    ext = extensions.find { |extension| File.exist?("#{base}.#{extension}") }
    raise("Count not find web response for #{path}") if ext.nil?

    return JSON.parse(IO.read("#{base}.#{ext}")) if json
    IO.read("#{base}.#{ext}")
  end
end
