module ErrorRequestMock
  def post_error_request(api_key, api_secret, data, client_version: '5', client: 'raven-ruby/0.15.2', encoding: 'other')
    if encoding == 'gzip'
      encoding_type = 'gzip'
      encoded_data = ActiveSupport::Gzip.compress(data)
    elsif encoding == 'deflate'
      encoding_type = 'deflate'
      encoded_data = StringIO.new(Zlib::Deflate.deflate(data))
    else
      encoding_type = 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3'
      encoded_data = StringIO.new(Zlib::Deflate.deflate(Base64.strict_encode64(data)))
    end

    ActionDispatch::Request.new(
      'REQUEST_METHOD' => 'POST',
      'HTTP_X_SENTRY_AUTH' => "Sentry sentry_version=#{client_version}, sentry_client=#{client}, sentry_timestamp=1455616740, sentry_key=#{api_key}, sentry_secret=#{api_secret}",
      'HTTP_ACCEPT_ENCODING' => encoding_type,
      'rack.input' => encoded_data
    )
  end

  # TODO create this method
  def get_error_request(api_key, data, client_version: '5', client: 'raven-js/0.15.2')
    ActionDispatch::Request.new(
      'REQUEST_METHOD' => 'GET',
      # 'HTTP_X_SENTRY_AUTH' => "Sentry sentry_version=#{client_version}, sentry_client=#{client}, sentry_timestamp=1455616740, sentry_key=#{api_key}, sentry_secret=#{api_secret}",
      # 'HTTP_ACCEPT_ENCODING' => encoding_type,
      # 'rack.input' => encoded_data
    )
  end
end
