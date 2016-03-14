require 'rails_helper'

RSpec.describe ErrorStore::Error do
  let(:website) { create :website }
  let(:group) { create :grouped_issue, website: website }
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_error) { create :issue, subscriber: subscriber, group: group, event_id: '8af060b2986f5914764d49b7f39b036c' }

  let(:time_now) { Time.parse('2016-02-10') }
  let(:post_request) { post_error_request(website.app_key, website.app_secret, web_response_factory('ruby_exception')) }
  let(:get_request) { get_error_request(website.app_key, web_response_factory('js_exception')) }
  let(:data) { JSON.parse(issue_error.data, symbolize_names: true) }
  let(:error) { ErrorStore::Error.new(request: post_request) }

  describe 'intialize' do
    it 'assigns request and issue provided' do
      expect( ErrorStore::Error.new(request: post_request).instance_variable_get(:@request) ).to eq(post_request)
      expect( ErrorStore::Error.new(issue: issue_error).instance_variable_get(:@issue) ).to eq(issue_error)
    end
  end

  describe 'find' do
    subject { ErrorStore::Error.new(issue: issue_error).find }
    it 'assigns the data to the class' do
      expect( subject.instance_variable_get(:@data) ).to eq(data)
    end
    it 'returns the class with data' do
      expect( subject ).to be_kind_of(ErrorStore::Error)
      expect( subject.data ).to eq(data)
    end
  end

  describe 'create!' do
    # i need this new request because we do body.read on the initial one so using the above
    # would result in an error
    let(:new_request) { post_error_request(website.app_key, website.app_secret, web_response_factory('ruby_exception')) }
    let!(:event_id) { error.create! }
    let(:cache_key) { "issue:#{website.id}:#{event_id}" }

    it 'assigns context' do
      expect( error.context ).to be_kind_of(ErrorStore::Context)
    end
    it 'gets the website' do
      expect( error.context.website ).to eq(website)
    end
    it 'assigns data validated' do
      expect( error.data ).to eq(validated_request(new_request))
      expect( error.data ).not_to be_nil
    end
    it 'returns the event_id' do
      expect( event_id ).to eq(issue_error.event_id)
      expect( event_id ).not_to be_nil
    end
    it 'saves to cache the data with key' do
      cache_value = Rails.cache.read(cache_key)
      expect( cache_value ).not_to be_nil
      expect( cache_value ).to eq(error.data)
      expect( cache_value ).to eq(validated_request(new_request))
    end
    it 'calls ErrorWorker' do
      expect( ErrorStore::Error::ErrorWorker.jobs.size ).to eq(1)
    end
  end

  describe 'get_website' do
    before do
      error.instance_variable_set(:@context, ErrorStore::Context.new(error))
      error.get_website
    end

    it 'assigns auth' do
      expect( error.auth ).not_to be_nil
    end
    it 'raises MissingCredentials if missing api key' do
      post_request.headers['HTTP_X_SENTRY_AUTH'] = "Sentry sentry_version='5', sentry_client='raven-ruby/0.15.2',sentry_timestamp=1455616740"
      expect { ErrorStore::Error.new(request: post_request).get_website }.to raise_exception(ErrorStore::MissingCredentials)
    end
    it 'raises MissingCredentials if missing api secret' do
      post_request.headers['HTTP_X_SENTRY_AUTH'] = "Sentry sentry_version='5', sentry_client='raven-ruby/0.15.2',sentry_timestamp=1455616740"
      expect { ErrorStore::Error.new(request: post_request).get_website }.to raise_exception(ErrorStore::MissingCredentials)
    end
    it 'assigns website to context' do
      expect( error.instance_variable_get(:@context).website ).to eq(website)
    end
    it 'raises WebsiteMissing if website does not exist with api key' do
      post_request.headers['HTTP_X_SENTRY_AUTH'] = "Sentry sentry_version='5', sentry_client='raven-ruby/0.15.2',sentry_timestamp=1455616740,sentry_key=coco,sentry_secret=soco"
      expect { ErrorStore::Error.new(request: post_request).get_website }.to raise_exception(ErrorStore::WebsiteMissing)
    end
    it 'raises MissingCredentials if post request and api_secret is different' do
      post_request.headers['HTTP_X_SENTRY_AUTH'] = "Sentry sentry_version='5', sentry_client='raven-ruby/0.15.2',sentry_timestamp=1455616740,sentry_key=#{website.app_key},sentry_secret=soco"
      some_error = ErrorStore::Error.new(request: post_request)
      some_error.instance_variable_set(:@context, ErrorStore::Context.new(some_error))
      expect { some_error.get_website }.to raise_exception(ErrorStore::MissingCredentials)
    end
  end

  describe 'validate_data' do
    let(:response) { web_response_factory('ruby_exception', json: true) }
    let(:request) { post_error_request(website.app_key, website.app_secret, response.to_json) }
    let(:valid_error) { ErrorStore::Error.new(request: request) }
    let(:string_io) { StringIO.new(Base64.strict_encode64(Zlib::Deflate.deflate(web_response_factory('ruby_exception')))) }

    it 'returns data[:message] = <no message> if message missing' do
      response.delete('message')
      valid_error.create!
      expect( valid_error.data[:message] ).to eq('<no message>')
    end
    it 'trims culprit length if too big' do
      # we set a 220 string as culprit
      response['culprit'] = '71raym9wwz3xv2zqyuve7hvpii5hxtvj5t0s6sg0rddbzq6f92hzmhmrdwma05tptvnu110bnftbt9dk0tx1d74iy02jpkzn95vrglwjb4ss4qvjko65hynxg5rtl0atyrqnjjcxcfddz1x62v3uj2x9iljjqzxolube9hweqv3py65o1h7glsmd9ng5n5pqe3y5u5vi820xsr6vfgld2wwtp4kj'
      valid_error.create!
      expect( valid_error.data[:culprit].length ).to eq(ErrorStore::MAX_CULPRIT_LENGTH)
    end
    it 'returns data[:event_id] equal to SecureRandom.hex if missing' do
      allow(SecureRandom).to receive(:hex).and_return('b7fb6019862bc1bc51d5587a146159f8')
      response.delete('event_id')
      valid_error.create!
      expect( valid_error.data[:event_id] ).to eq(SecureRandom.hex)
    end
    it 'returns data[:errors] value_too_long if event_id too big' do
      response['event_id'] = '71raym9wwz3xv2zqyuve7hvpii5hxtvj5t0s6sg0rddbzq6f92hzmhmrdwma05tptvnu110bnftbt9d'
      valid_error.create!
      expect( valid_error.data[:errors] ).to include(
        {
          type: 'value_too_long', name: 'event_id',
          value: '71raym9wwz3xv2zqyuve7hvpii5hxtvj5t0s6sg0rddbzq6f92hzmhmrdwma05tptvnu110bnftbt9d'
        }
      )
    end
    it 'returns data[:timestamp] equal to Time.now.utc if missing' do
      Timecop.freeze(time_now) do
        response.delete('timestamp')
        valid_error.create!
        expect( valid_error.data[:timestamp] ).to eq(time_now)
      end
    end
    it 'returns data[:errors] invalid_data if can not process timestamp'
    it 'returns the right timestamp'
    it 'returns the processed fingerprint'
    it 'returns data[:errors] invalid_data if InvalidFingerprint'
    it 'returns data[:platform] as other if is not in VALID_PLATFORMS' do
      error.create!
      _data = JSON.parse(web_response_factory('ruby_exception'), symbolize_names: true)
      _data[:platform] = "shagaron"
      error.request.headers["rack.input"] = StringIO.new(Base64.strict_encode64(Zlib::Deflate.deflate(_data.to_json)))
      expect( error.validate_data[:platform] ).to eq("other")
    end
    it 'returns data[:platform] trimed at 64 event if in VALID_PLATFORMS' do
      error.create!
      error.request.headers["rack.input"] = string_io
      expect( error.validate_data[:platform] ).to eq("ruby")
    end
    # it 'returns data[:errors] invalid_data if modules is not a Hash and is set' do
    #   error.create!
    #   _data = JSON.parse(web_response_factory('ruby_exception'), symbolize_names: true)
    #   _data[:modules] = "string"
    #   error.request.headers["rack.input"] = StringIO.new(Base64.strict_encode64(Zlib::Deflate.deflate(_data.to_json)))
    #   error.validate_data
    #   Rails.logger.error -> true????
    # end
    # it 'returns data[:errors] invalid data if extra is not a Hash and is set' do
    #   error.create!
    #   _data = JSON.parse(web_response_factory('ruby_exception'), symbolize_names: true)
    #   _data[:extra] = "string"
    #   error.request.headers["rack.input"] = StringIO.new(Base64.strict_encode64(Zlib::Deflate.deflate(_data.to_json)))
    #   error.validate_data
    #   Rails.logger.error -> true????
    # end
    it 'removes extra if error' do
      error.create!
      _data = JSON.parse(web_response_factory('ruby_exception'), symbolize_names: true)
      _data[:extra] = "string"
      error.request.headers["rack.input"] = StringIO.new(Base64.strict_encode64(Zlib::Deflate.deflate(_data.to_json)))
      expect( error.validate_data[:extra] ).to be_nil
    end
    it 'trims data[:extra] to max_size of MAX_VARIABLE_SIZE' do
      error.create!
      _data = JSON.parse(web_response_factory('ruby_exception'), symbolize_names: true)
      _data[:extra][:param] = issue_error.data
      error.request.headers["rack.input"] = StringIO.new(Base64.strict_encode64(Zlib::Deflate.deflate(_data.to_json)))
      expect( error.validate_data[:extra][:param].length ).to eq(512)
    end
    # it 'removes all the CLIENT_RESERVED_ATTRS' do
    #   error.create!
    #   error.request.headers["rack.input"] = string_io
    #   expect(  error.validate_data.keys.to_set ).to eq(ErrorStore::CLIENT_RESERVED_ATTRS.to_set)
    #   ????
    # end
    it 'adds data[:errors] invalid_attribute if InvalidInterface'
    it 'adds data[:errors] if invalid_data and value is not a hash or an array'
    it 'adds the right interface to data[:interfaces]'
    it 'adds data[:errors] invalid_data if error on sanitize_data or to_json' do
      # error.data["description"] = "iPhone\xAE"
    end
    it 'sets DEFAULT_LOG_LEVEL if level is empty' do
      error.create!
      error.request.headers["rack.input"] = string_io
      error.data[:level] = nil
      expect( error.validate_data[:level] ).to eq(ErrorStore::DEFAULT_LOG_LEVEL)
    end
    it 'sets DEFAULT_LOG_LEVEL if level is not numeric' do
      error.create!
      error.request.headers["rack.input"] = string_io
      error.data[:level] = "string"
      expect( error.validate_data[:level] ).to eq(ErrorStore::DEFAULT_LOG_LEVEL)
    end
    it 'adds data[:errors] invalid_data if level does not exist'
    it 'encodes release to utf-8' do
      error.create!
      _data = JSON.parse(web_response_factory('ruby_exception'), symbolize_names: true)
      _data[:release] = "some string"
      error.request.headers["rack.input"] = StringIO.new(Base64.strict_encode64(Zlib::Deflate.deflate(_data.to_json)))
      binding.pry
      # expect( error.validate_data[:release].encoding ).to eq(#<Encoding:UTF-8>)
    end
    it 'adds data[:errors] value_too_long if release bigger than 64' do
      error.create!
      _data = JSON.parse(web_response_factory('ruby_exception'), symbolize_names: true)
      error.request.headers["rack.input"] = string_io
      _data[:release] = "Ruby was conceived on February 24, 1993. In a 1999 post to the ruby-talk mailing list, Ruby author Yukihiro Matsumoto describes some of his early ideas about the language"
      error.request.headers["rack.input"] = StringIO.new(Base64.strict_encode64(Zlib::Deflate.deflate(_data.to_json)))
      expect( error.validate_data[:release] ).to be_nil
      # expect( error.validate_data[:release][:errors][0][:type] ).to eq("value_too_long")
    end
    it 'returns the right release' do
      error.create!
      _data = JSON.parse(web_response_factory('ruby_exception'), symbolize_names: true)
      _data[:release] = "some string"
      error.request.headers["rack.input"] = StringIO.new(Base64.strict_encode64(Zlib::Deflate.deflate(_data.to_json)))
      expect( error.validate_data[:release] ).to eq("some string")
    end
    it 'returns the data[:version] from auth' do
      error.create!
      error.request.headers["rack.input"] = string_io
      expect( error.validate_data[:version] ).to eq("5")
    end
    # it 'returns the expected validated data' do
    #   error.create!
    #   error.request.headers["rack.input"] = string_io
    #   error.validate_data
    # end
  end

  describe 'ErrorWorker' do
    let(:data_with_website) { JSON.parse(web_response_factory('ruby_exception'), symbolize_names: true) }
    # it 'removes cache key after doing store' do
    #   cache_key = "issue:#{website.id}:#{issue_error.event_id}"
    #   Rails.cache.write(cache_key, data_with_website)
    #   ErrorStore::Error::ErrorWorker.new.perform(cache_key)
    #   expect( Rails.cache.read(cache_key) ).to be_nil
    # end
    # it 'returns and sets logger if cache not set', truncation: true do
    #   cache_key = "issue:#{website.id}:#{issue_error.event_id}"
    #   Rails.cache.delete(cache_key)
    #   expect(Rails.logger).to receive(:info).with("Data is not available for #{cache_key} in ErrorWorker.perform")
    #   ErrorStore::Error::ErrorWorker.new.perform(cache_key)
    # end
  end

  describe '_params' do
    let(:params) { {"param" => "some params here"} }

    it 'returns the request parameters' do
      error.request.parameters.merge!(params)
      expect( error._params ).to eq(params)
    end
  end

  describe '_auth' do
    it 'returns the auth assigned' do
      error.create!
      expect( error._auth.kind_of?(ErrorStore::Auth) ).to be(true)
    end
  end

  describe '_website' do
    it 'returns the context website' do
      error.create!
      expect( error._website ).to eq(website)
    end
    it 'returns nil if website not set on context' do
      error.create!
      error.context.remove_instance_variable(:@website)
      expect( error._website ).to be_nil
    end
  end

  describe '_get_interfaces' do
    it 'returns [] if no interfaces in data' do
      expect( issue_error.get_interfaces ).to eq([])
    end
    it 'returns all interfaces'
  end

  describe 'get_data' do
    let(:get_error_example) { ErrorStore::Error.new(request: get_request) }
    it 'gets all the params if get request' do
      expect( get_error_example.request.params[:sentry_data].blank? ).to be(false)
    end
    # it 'reads the body if post request' do
    #   ???
    #   expect(error.request.body).to receive(:read)
    #   error.get_data
    # end
    # it 'does decompress_gzip if content_encoding is gzip' do
    #   error.request.headers['HTTP_ACCEPT_ENCODING'] = 'gzip'
    #   error.request.headers["rack.input"] = ActiveSupport::Gzip.compress("random string")
    #   allow_any_instance_of(ErrorStore::Utils).to receive(:decompress_gzip)
    #   error.get_data
    # end
    # it 'does decompress_deflate if content_encoding is deflate' do
    #   error.request.headers['HTTP_ACCEPT_ENCODING'] = 'deflate'
    #   error.request.headers["rack.input"] = StringIO.new(Zlib::Deflate.deflate("random string"))
    #   allow_any_instance_of(ErrorStore::Utils).to receive(:decompress_deflate)
    #   error.get_data
    # end
    # it 'does decode_and_decompress if data starts with {' do
    #   allow_any_instance_of(ErrorStore::Utils).to receive(:decode_and_decompress)
    #   error.get_data
    # end
    it 'returns decoded json data' do
      expect( error.get_data ).to eq(JSON.parse(web_response_factory('ruby_exception'), symbolize_names: true))
    end
  end

  describe 'process_fingerprint' do
    it 'raises InvalidFingerprint if it is not an array' do
      expect{ error.process_fingerprint(data) }.to raise_exception(ErrorStore::InvalidFingerprint)
    end
    it 'raises InvalidFingerprint if section is not numeric' do
      data[:fingerprint] = ['not numeric']
      expect{ error.process_fingerprint(data) }.to raise_exception(ErrorStore::InvalidFingerprint)
    end
    it 'returns the right sections' do
      data[:fingerprint] = ["2"]
      expect( error.process_fingerprint(data) ).to eq(["2"])
    end
  end

  xdescribe 'process_timestamp'
end
