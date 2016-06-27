require 'rails_helper'

RSpec.describe ErrorStore::Error do
  let(:user) { create :user }
  let(:website) { create :website }
  let!(:website_member) { create :website_member, user: user, website: website }
  let(:release) { create :release, website: website }
  let(:group) { create :grouped_issue, website: website, release: release }
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_error) { create :issue, subscriber: subscriber, group: group, event_id: '8af060b2986f5914764d49b7f39b036c' }

  let(:time_now) { Time.parse('2016-02-10') }
  let(:post_request) { post_error_request(web_response_factory('ruby_exception'), website) }
  let(:get_request) { get_error_request(web_response_factory('js_exception', json: true), website) }
  let(:data) { JSON.parse(issue_error.data, symbolize_names: true) }
  let(:error) { ErrorStore::Error.new(request: post_request) }
  let(:assign_context) { error.instance_variable_set(:@context, ErrorStore::Context.new(error)) }

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
    temp_enable_dalli_cache!
    # i need this new request because we do body.read on the initial one so using the above
    # would result in an error
    let(:new_request) { post_error_request(web_response_factory('ruby_exception'), website) }
    let!(:event_id) { error.create! }
    let(:cache_key) { "issue:#{website.id}:#{event_id}" }

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

  describe 'check_origin' do
    let(:website2) { create :website, origins: '' }

    it 'raises MissingCredentials if blank origin and get request' do
      error.request.headers.env.delete('HTTP_ORIGIN')
      error.request.headers.env['REQUEST_METHOD'] = "GET"
      assign_context

      expect { error.check_origin }.to raise_exception(ErrorStore::MissingCredentials)
    end

    it 'raises MissingCredentials if blank origin && post request && app_secret does not match' do
      error.request.headers.env.delete('HTTP_ORIGIN')
      assign_context
      error.context.website = website2

      expect { error.check_origin }.to raise_exception(ErrorStore::MissingCredentials)
    end

    it 'raises WebsiteMissing if no website' do
      expect { error.check_origin }.to raise_exception(ErrorStore::WebsiteMissing)
    end

    it 'raises InvalidOrigin if invalid origin' do
      assign_context
      error.context.website = website2
      expect { error.check_origin }.to raise_exception(ErrorStore::InvalidOrigin)
    end
  end

  describe 'assign_website' do
    before do
      assign_context
      error.assign_website
    end

    it 'raises MissingCredentials if missing api key' do
      post_request.headers['HTTP_X_SENTRY_AUTH'] = "Sentry sentry_version='5', sentry_client='raven-ruby/0.15.2',sentry_timestamp=1455616740"
      expect { ErrorStore::Error.new(request: post_request).assign_website }.to raise_exception(ErrorStore::MissingCredentials)
    end
    it 'raises MissingCredentials if missing api secret' do
      post_request.headers['HTTP_X_SENTRY_AUTH'] = "Sentry sentry_version='5', sentry_client='raven-ruby/0.15.2',sentry_timestamp=1455616740"
      expect { ErrorStore::Error.new(request: post_request).assign_website }.to raise_exception(ErrorStore::MissingCredentials)
    end
    it 'assigns website to context' do
      expect( error.instance_variable_get(:@context).website ).to eq(website)
    end
    it 'raises WebsiteMissing if website does not exist with api key' do
      post_request.headers['HTTP_X_SENTRY_AUTH'] = "Sentry sentry_version='5', sentry_client='raven-ruby/0.15.2',sentry_timestamp=1455616740,sentry_key=coco,sentry_secret=soco"
      expect { ErrorStore::Error.new(request: post_request).assign_website }.to raise_exception(ErrorStore::WebsiteMissing)
    end
    it 'raises MissingCredentials if post request and api_secret is different' do
      post_request.headers['HTTP_X_SENTRY_AUTH'] = "Sentry sentry_version='5', sentry_client='raven-ruby/0.15.2',sentry_timestamp=1455616740,sentry_key=#{website.app_key},sentry_secret=soco"
      some_error = ErrorStore::Error.new(request: post_request)
      some_error.instance_variable_set(:@context, ErrorStore::Context.new(some_error))
      expect { some_error.assign_website }.to raise_exception(ErrorStore::MissingCredentials)
    end
  end

  describe 'validate_data' do
    let(:response) { web_response_factory('ruby_exception', json: true) }
    let(:request) { post_error_request(response.to_json, website) }
    let(:valid_error) { ErrorStore::Error.new(request: request) }
    subject { valid_error.create! }

    it 'returns data[:message] = <no message> if message missing' do
      response.delete('message')
      subject
      expect( valid_error.data[:message] ).to eq('<no message>')
    end
    it 'trims culprit length if too big' do
      # we set a 220 string as culprit
      response['culprit'] = '71raym9wwz3xv2zqyuve7hvpii5hxtvj5t0s6sg0rddbzq6f92hzmhmrdwma05tptvnu110bnftbt9dk0tx1d74iy02jpkzn95vrglwjb4ss4qvjko65hynxg5rtl0atyrqnjjcxcfddz1x62v3uj2x9iljjqzxolube9hweqv3py65o1h7glsmd9ng5n5pqe3y5u5vi820xsr6vfgld2wwtp4kj'
      subject
      expect( valid_error.data[:culprit].length ).to eq(ErrorStore::MAX_CULPRIT_LENGTH)
    end
    it 'returns data[:event_id] equal to SecureRandom.hex if missing' do
      allow(SecureRandom).to receive(:hex).and_return('b7fb6019862bc1bc51d5587a146159f8')
      response.delete('event_id')
      subject
      expect( valid_error.data[:event_id] ).to eq(SecureRandom.hex)
    end
    it 'returns data[:errors] value_too_long if event_id too big' do
      response['event_id'] = '71raym9wwz3xv2zqyuve7hvpii5hxtvj5t0s6sg0rddbzq6f92hzmhmrdwma05tptvnu110bnftbt9d'
      subject
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
        subject
        expect( valid_error.data[:timestamp] ).to eq(time_now.to_i)
      end
    end
    it 'returns data[:errors] invalid_data if can not process timestamp' do
      response['timestamp'] = 'jj'
      subject
      expect( valid_error.data[:errors] ).to include({:type=>"invalid_data", :name=>"timestamp", :value=>"jj"})
    end
    it 'returns the right timestamp' do
      current_datetime = '2016-02-17T12:29:56Z'
      Timecop.freeze(current_datetime) do
        subject
        value = DateTime.strptime(current_datetime, '%Y-%m-%dT%H:%M:%S')
        expect( valid_error.data[:timestamp] ).to eq(value.strftime('%s').to_i)
      end
    end

    it 'returns the processed fingerprint' do
      response['fingerprint'] = 'qweqwe'
      subject
      expect( valid_error.data[:fingerprint] ).to be_nil
    end

    it 'returns data[:errors] invalid_data if InvalidFingerprint' do
      response[:fingerprint] = {}
      subject
      expect( valid_error.data[:fingerprint] ).to be_nil
      expect( valid_error.data[:errors] ).to include({:type=>"invalid_data", :name=>"fingerprint", :value=>{}})
    end
    it 'returns data[:platform] as other if is not in VALID_PLATFORMS' do
      response['platform'] = "shagaron"
      subject
      expect( valid_error.data[:platform] ).to eq("other")
    end
    it 'returns data[:platform] trimed at 64 event if in VALID_PLATFORMS' do
      subject
      expect( valid_error.data[:platform] ).to eq("ruby")
    end
    it 'returns data[:errors] invalid_data if modules is not a Hash and is set' do
      response['modules'] = "string"
      subject
      expect( valid_error.data[:errors] ).to include({:type=>"invalid_data", :name=>"modules", :value=>"string"})
    end
    it 'returns data[:errors] invalid data if extra is not a Hash and is set' do
      response['extra'] = "string"
      subject
      expect( valid_error.data[:errors] ).to include({:type=>"invalid_data", :name=>"extra", :value=>"string"})
    end
    it 'removes extra if error' do
      response['extra'] = "string"
      subject
      expect( valid_error.data[:extra] ).to be_nil
    end
    it 'trims data[:extra] to max_size of MAX_VARIABLE_SIZE' do
      response['extra']['param'] = issue_error.data
      subject
      expect( valid_error.data[:extra][:param].length ).to eq(512)
    end
    it 'removes all attrs that are not in CLIENT_RESERVED_ATTRS' do
      response[:cacamaca] = ''
      subject
      expect( valid_error.data[:cacamaca] ).to be_nil
    end
    it 'adds data[:errors] invalid_attribute if InvalidInterface' do
      response['cacamaca'] = 'here is some weird stuff'
      subject
      expect( valid_error.data[:errors] ).to include({ :type=>"invalid_attribute", :name=>:cacamaca })
    end
    it 'adds data[:errors] if invalid_data and value is not a hash or an array' do
      response['cacamaca'] = 'here is some weird stuff'
      subject
      expect( valid_error.data[:errors] ).to include({ :type=>"invalid_data", :name=>:cacamaca, :value=>"here is some weird stuff" })
    end
    it 'adds the right interface to data[:interfaces]' do
      subject
      expect( valid_error.data[:interfaces][:exception] ).not_to be_nil
    end
    it 'adds data[:errors] invalid_data if error on sanitize_data or to_json' do
      exception_data = JSON.parse(response.to_json, symbolize_names: true)
      allow_any_instance_of(ErrorStore::Interfaces::Exception).to receive(:sanitize_data).and_raise(ErrorStore::ValidationError)
      subject
      expect( valid_error.data[:errors] ).to include(include({ :type=>"invalid_data", :name=>:exception, :value=> exception_data[:exception] }))
    end
    it 'sets DEFAULT_LOG_LEVEL if level is empty' do
      response['level'] = nil
      subject
      expect( valid_error.data[:level] ).to eq(ErrorStore::DEFAULT_LOG_LEVEL)
    end
    it 'sets DEFAULT_LOG_LEVEL if level is not numeric' do
      response['level'] = "string"
      subject
      expect( valid_error.data[:level] ).to eq(ErrorStore::DEFAULT_LOG_LEVEL)
    end

    it 'adds data[:errors] invalid_data if level does not exist' do
      response[:level] = 60
      subject
      expect( valid_error.data[:errors] ).to include({ :type=>"invalid_data", :name=>'level', :value=> 60 })
      expect( valid_error.data[:level] ).to eq(ErrorStore::DEFAULT_LOG_LEVEL)
    end

    it 'encodes release to utf-8' do
      response['release'] = "some string"
      subject
      expect( valid_error.data[:release].encoding ).to eq(Encoding.find('UTF-8'))
    end
    it 'adds data[:errors] value_too_long if release bigger than 64' do
      response['release'] = "Ruby was conceived on February 24, 1993. In a 1999 post to the ruby-talk mailing list, Ruby author Yukihiro Matsumoto describes some of his early ideas about the language"
      subject
      expect( valid_error.data[:errors] ).to include(
        {
          type: 'value_too_long', name: 'release',
          value: 'Ruby was conceived on February 24, 1993. In a 1999 post to the ruby-talk mailing list, Ruby author Yukihiro Matsumoto describes some of his early ideas about the language'
        }
      )
      expect( valid_error.data[:release] ).to be_nil
    end
    it 'returns the right release' do
      response['release'] = "some string"
      subject
      expect( valid_error.data[:release] ).to eq("some string")
    end
    it 'returns the data[:version] from auth' do
      subject
      expect( valid_error.data[:version] ).to eq("5")
    end
    it 'returns the expected validated data' do
      post_request = post_error_request(web_response_factory('ruby_exception'), website)
      subject
      expect( valid_error.data ).to eq(validated_request(post_request))
    end
  end

  describe 'ErrorWorker', truncation: true do
    let(:post_request) { post_error_request(web_response_factory('ruby_exception'), website) }
    let(:validated_post_data) { validated_request(post_request) }
    let(:cache_key) { "issue:#{website.id}:#{validated_post_data[:event_id]}" }
    it 'removes cache key after doing store' do
      Rails.cache.write(cache_key, validated_post_data)
      ErrorStore::Error::ErrorWorker.new.perform(cache_key)
      expect( Rails.cache.read(cache_key) ).to be_nil
    end
    it 'returns and sets logger if cache not set' do
      expect(Rails.logger).to receive(:error).with('Data is not available for sexy in ErrorWorker.perform')
      ErrorStore::Error::ErrorWorker.new.perform('sexy')
    end
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

  describe '_context' do
    it 'returns the context assigned' do
      error.create!
      expect( error._context.kind_of?(ErrorStore::Context) ).to be(true)
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
    let(:response) { web_response_factory('ruby_exception', json: true) }
    let(:request) { post_error_request(response.to_json, website) }
    let(:valid_error) { ErrorStore::Error.new(request: request) }
    it 'returns [] if no interfaces in data' do
      response['exception'] = ''
      response['user'] = ''
      response['request'] = ''
      response['template'] = ''
      response['query'] = ''

      valid_error.create!
      expect( valid_error._get_interfaces ).to eq([])
    end
    it 'returns all interfaces' do
      valid_error.create!
      expect( valid_error._get_interfaces ).to include(an_instance_of(ErrorStore::Interfaces::Exception))
      expect( valid_error._get_interfaces ).to include(an_instance_of(ErrorStore::Interfaces::Http))
      expect( valid_error._get_interfaces ).to include(an_instance_of(ErrorStore::Interfaces::User))
      expect( valid_error._get_interfaces ).to include(an_instance_of(ErrorStore::Interfaces::Template))
      expect( valid_error._get_interfaces ).to include(an_instance_of(ErrorStore::Interfaces::Query))
      expect( valid_error._get_interfaces.length ).to eq(5)
    end
  end

  describe 'get_data' do
    let(:post_error) { ErrorStore::Error.new(request: post_request) }
    let(:get_error) { ErrorStore::Error.new(request: get_request) }
    let(:get_data) { JSON.parse(web_response_factory('js_exception'), symbolize_names: true) }
    let(:post_data) { JSON.parse(web_response_factory('ruby_exception'), symbolize_names: true) }

    it 'gets all the params if get request' do
      expect( get_error.get_data ).to eq(get_data)
    end
    it 'reads the body if post request' do
      expect( post_error.get_data ).to eq(post_data)
    end
    it 'does decompress_gzip if content_encoding is gzip' do
      gzip_request = post_error_request(web_response_factory('ruby_exception'), website, encoding: 'gzip')
      post_error = ErrorStore::Error.new(request: gzip_request)
      expect( post_error ).to receive(:decompress_gzip).and_return(web_response_factory('ruby_exception'))
      expect( post_error.get_data ).to eq(post_data)
    end
    it 'does decompress_deflate if content_encoding is deflate' do
      deflate_request = post_error_request(web_response_factory('ruby_exception'), website, encoding: 'deflate')
      post_error = ErrorStore::Error.new(request: deflate_request)
      expect( post_error ).to receive(:decompress_deflate).and_return(web_response_factory('ruby_exception'))
      expect( post_error.get_data ).to eq(post_data)
    end
    it 'does decode_and_decompress if data does not start with {' do
      expect( post_error ).to receive(:decode_and_decompress).and_return(web_response_factory('ruby_exception'))
      expect( post_error.get_data ).to eq(post_data)
    end
    it 'returns decoded json data' do
      expect( post_error.get_data ).to be_a(Hash)
      expect( get_error.get_data ).to be_a(Hash)
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
end
