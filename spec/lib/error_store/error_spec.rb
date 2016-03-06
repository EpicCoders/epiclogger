require 'rails_helper'

RSpec.describe ErrorStore::Error do
  let(:website) { create :website }
  let(:group) { create :grouped_issue, website: website }
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_error) { create :issue, subscriber: subscriber, group: group, event_id: '8af060b2986f5914764d49b7f39b036c' }

  let(:post_request) { post_error_request(website.app_key, website.app_secret, web_response_factory('ruby_exception')) }
  let(:get_request) { get_error_request(website.app_key, web_response_factory('js_exception')) }
  let(:data) { JSON.parse(issue_error.data, symbolize_names: true) }
  let(:error) { ErrorStore::Error.new(request: post_request) }

  # before { request.parameters.merge!("format"=>:json, "controller"=>"api/v1/store", "action"=>"create", "id"=>"1") }

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

  xdescribe 'validate_data' do
    it 'returns data[:message] = <no message> if message missing'
    it 'trims culprint length if too big'
    it 'returns data[:event_id] equal to SecureRandom.hex if missing'
    it 'returns data[:errors] value_too_long if event_id too big'
    it 'returns data[:timestamp] equal to Time.now.utc if missing'
    it 'returns data[:errors] invalid_data if can not process timestamp'
    it 'returns the right timestamp'
    it 'returns the processed fingerprint'
    it 'returns data[:errors] invalid_data if InvalidFingerprint'
    it 'returns data[:platform] as other if is not in VALID_PLATFORMS'
    it 'returns data[:platform] trimed at 64 event if in VALID_PLATFORMS'
    it 'returns data[:errors] invalid_data if modules is not a Hash and is set'
    it 'returns data[:errors] invalid data if extra is not a Hash and is set'
    it 'removes extra if error'
    it 'trims data[:extra] to max_size of MAX_VARIABLE_SIZE'
    it 'removes all the CLIENT_RESERVED_ATTRS'
    it 'adds data[:errors] invalid_attribute if InvalidInterface'
    it 'adds data[:errors] if invalid_data and value is not a hash or an array'
    it 'adds the right interface to data[:interfaces]'
    it 'adds data[:errors] invalid_data if error on sanitize_data or to_json'
    it 'sets DEFAULT_LOG_LEVEL if level is empty'
    it 'sets DEFAULT_LOG_LEVEL if level is not numeric'
    it 'adds data[:errors] invalid_data if level does not exist'
    it 'encodes release to utf-8'
    it 'adds data[:errors] value_too_long if release bigger than 64'
    it 'returns the right release'
    it 'returns the data[:version] from auth'
    it 'returns the expected validated data'
  end

  xdescribe 'ErrorWorker' do
    it 'removes cache key after doing store'
    it 'returns and sets logger if cache not set'
  end

  xdescribe '_params' do
    it 'returns the request parameters'
  end

  describe '_auth' do
    it 'returns the auth assigned' do
      # expect_any_instance_of(ErrorStore::Error).to receive(:_auth).and_return()
      # ErrorStore::Error.new(request: request, issue: issue_error)._auth
    end
  end

  xdescribe '_website' do
    it 'returns the context website'
    it 'returns nil if website not set on context'
  end

  xdescribe '_get_interfaces' do
    it 'returns [] if no interfaces in data'
    it 'returns all interfaces'
  end

  xdescribe 'get_data' do
    it 'gets all the params if get request'
    it 'reads the body if post request'
    it 'does decompress_gzip if content_encoding is gzip'
    it 'does decompress_deflate if content_encoding is deflate'
    it 'does decode_and_decompress if data starts with {'
    it 'returns decoded json data'
  end

  xdescribe 'process_fingerprint' do
    it 'raises InvalidFingerprint if it is not an array'
    it 'raises InvalidFingerprint if section is not numeric'
    it 'returns the right sections'
  end

  describe 'process_timestamp' do
    # expect(ErrorStore::Error.new(request: request, issue: issue_error).process_timestamp(data)).to eq(data)
  end
end
