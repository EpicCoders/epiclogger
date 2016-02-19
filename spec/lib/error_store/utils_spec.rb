require 'rails_helper'

RSpec.describe ErrorStore::Utils do
  let(:website) { create :website }
  let(:group) { create :grouped_issue, website: website }
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_error) { create :issue, subscriber: subscriber, group: group }
  let(:request) { post_error_request(website.app_key, website.app_secret, web_response_factory('ruby_exception')) }

  describe 'is_numeric?' do
    it 'returns true for numeric' do
      expect(ErrorStore::Error.new.is_numeric?(1)).to eq(true)
    end
    it 'returns false for chars' do
      expect(ErrorStore::Error.new.is_numeric?('random')).to eq(false)
    end
    it 'does not care if string or int it works' do
      expect(ErrorStore::Error.new.is_numeric?('1')).to eq(true)
    end
  end

  describe 'decode_json' do
    it 'parses valid json with symbolize_names' do
      expect(ErrorStore::Error.new.decode_json(issue_error.data).to_s).to eq('{:server_name=>"sergiu-Lenovo-IdeaPad-Y510P", :modules=>{:rake=>"10.4.2", :i18n=>"0.7.0", :json=>"1.8.3", :minitest=>"5.8.2", :thread_safe=>"0.3.5", :tzinfo=>"1.2.2", :activesupport=>"4.2.1", :builder=>"3.2.2", :erubis=>"2.7.0", :mini_portile=>"0.6.2", :nokogiri=>"1.6.6.2", :"rails-deprecated_sanitizer"=>"1.0.3", :"rails-dom-testing"=>"1.0.7", :loofah=>"2.0.3", :"rails-html-sanitizer"=>"1.0.2", :actionview=>"4.2.1", :rack=>"1.6.4", :"rack-test"=>"0.6.3", :actionpack=>"4.2.1", :globalid=>"0.3.6", :activejob=>"4.2.1", :"mime-types"=>"2.6.2", :mail=>"2.6.3", :actionmailer=>"4.2.1", :activemodel=>"4.2.1", :arel=>"6.0.3", :activerecord=>"4.2.1", :debug_inspector=>"0.0.2", :binding_of_caller=>"0.7.2", :bundler=>"1.11.2", :coderay=>"1.1.0", :"coffee-script-source"=>"1.10.0", :execjs=>"2.6.0", :"coffee-script"=>"2.4.1", :thor=>"0.19.1", :railties=>"4.2.1", :"coffee-rails"=>"4.1.0", :"multipart-post"=>"2.0.0", :faraday=>"0.9.2", :multi_json=>"1.11.2", :jbuilder=>"2.3.2", :"jquery-rails"=>"4.0.5", :method_source=>"0.8.2", :slop=>"3.6.0", :pry=>"0.10.3", :sprockets=>"3.4.0", :"sprockets-rails"=>"2.3.3", :rails=>"4.2.1", :rdoc=>"4.2.0", :sass=>"3.4.19", :tilt=>"2.0.1", :"sass-rails"=>"5.0.4", :sdoc=>"0.4.1", :"sentry-raven"=>"0.15.2", :spring=>"1.4.1", :sqlite3=>"1.3.11", :turbolinks=>"2.5.3", :uglifier=>"2.7.2", :"web-console"=>"2.2.1"}, :extra=>{}, :tags=>{}, :errors=>[{:type=>"invalid_data", :name=>"timestamp", :value=>"2016-02-15T06:01:29"}], :interfaces=>{:exception=>{:values=>[{:type=>"ZeroDivisionError", :value=>"\"divided by 0\"", :module=>"", :stacktrace=>{:frames=>[{:abs_path=>"/home/sergiu/.rvm/rubies/ruby-2.2.2/lib/ruby/2.2.0/webrick/server.rb", :filename=>"webrick/server.rb", :function=>"block in start_thread", :context_line=>"          block ? block.call(sock) : run(sock)\n", :pre_context=>["module ActionController\n", "  module ImplicitRender\n", "    def send_action(method, *args)\n"], :post_context=>["      default_render unless performed?\n", "      ret\n", "    end\n"], :lineno=>4}, {:abs_path=>"/home/sergiu/ravenapp/app/controllers/home_controller.rb", :filename=>"app/controllers/home_controller.rb", :function=>"index", :context_line=>"    1/0\n", :pre_context=>["  # Prevent CSRF attacks by raising an exception.\n", "  # For APIs, you may want to use :null_session instead.\n", "  def index\n"], :post_context=>["  end\n", "end\n", ""], :lineno=>5}, {:abs_path=>"/home/sergiu/ravenapp/app/controllers/home_controller.rb", :filename=>"app/controllers/home_controller.rb", :function=>"/", :context_line=>"    1/0\n", :pre_context=>["  # Prevent CSRF attacks by raising an exception.\n", "  # For APIs, you may want to use :null_session instead.\n", "  def index\n"], :post_context=>["  end\n", "end\n", ""], :lineno=>5}], :frames_omitted=>nil, :has_frames=>true}}], :exc_omitted=>nil}, :http=>{:env=>{:REMOTE_ADDR=>"127.0.0.1", :SERVER_NAME=>"localhost", :SERVER_PORT=>"3001"}, :headers=>[{:host=>"localhost:3001"}, {:connection=>"keep-alive"}, {:accept=>"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"}, {:upgrade_insecure_requests=>"1"}, {:user_agent=>"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.93 Safari/537.36"}, {:accept_encoding=>"gzip, deflate, sdch"}, {:accept_language=>"en-US,en;q=0.8"}, {:cookie=>"currentConfigName=%22default%22; pickedWebsite=1; _epiclogger_session=NTIwU2prYUd2T0dEd3FGQWE0WUFaL3RDY0huRGFnV1Z5TEhOQ3RtWUZZTTVRSzgvRTZvdEI2SFRsSVQ0ajVidHRWQnA5ck9wT3ZQU095N0dkWjEza0dpYWlmekxyRzFJbEFVNk5zRExmMzg3Q2c2MFBWdi9UYVUyWjdkWHVMNUFaWFJzZ2pEMGdwd3JJSGpSNjlEK2o3ZjlWZEhISEprK1hXOFNvaGdRdHg2MkFxN0lrcmlIdUtQazVWUjNGaWJvUGVYTHJncEc2OWhpaHBZbXNqcVhUcjM0ZWQ5bDFnWDBVSGlaOE5rdGxiOHNDU2NUS3BaSjd4eUZSRklzVnU5M3Z0TmJLUzF6ZWxjOGUrRmF2NkZ6ZCtGMUdoQVdFUSt0am9KT2lDODRMckJwbWQ1ZU5hV1hhZmt2bHdDZHZibEFmMExXNTI5Tmt..."}, {:version=>"HTTP/1.1"}], :url=>"http://localhost//"}}, :site=>nil, :environment=>nil, :version=>"5"}')
    end
    it 'raises BadData if invalid json' do
      expect { ErrorStore::Error.new.decode_json('random data') }.to raise_exception(ErrorStore::BadData)
    end
  end

  describe 'decode_and_decompress' do
    it 'does inflate of base64 data' do
      encoded_data = StringIO.new(Base64.strict_encode64(Zlib::Deflate.deflate('random_string')))
      expect( ErrorStore::Error.new.decode_and_decompress(encoded_data.read) ).to eq('random_string')
    end
    it 'does base64.decode if zlib error' do
      allow(Zlib::Inflate).to receive(:inflate).with('string').and_raise(Zlib::Error)
      # expect(Base64.decode64('string')).to eq("\xB2\xDA\xE2\x9E")
      # expect{ Zlib::Inflate.inflate(Base64.decode64(issue_error.data)) }.to raise_exception(Zlib::Error)
    end
    it 'raises BadData if invalid' do
      expect{ ErrorStore::Error.new.decode_and_decompress({key: 'value'}) }.to raise_exception(ErrorStore::BadData)
    end
  end

  describe 'decompress_deflate' do
    it 'does inflate of data' do
      encoded_data = StringIO.new(Zlib::Deflate.deflate('random_string'))
      expect( ErrorStore::Error.new.decompress_deflate(encoded_data.read) ).to eq('random_string')
    end
    it 'raises BadData if invalid' do
      expect{ ErrorStore::Error.new.decompress_deflate({key: 'value'}) }.to raise_exception(ErrorStore::BadData)
    end
  end

  describe 'decompress_gzip' do
    it 'does GzipReader on data' do
      encoded_data = ActiveSupport::Gzip.compress("random_string")
      expect( ErrorStore::Error.new.decompress_gzip(encoded_data) ).to eq('random_string')
    end
    it 'raises BadData if invalid' do
      expect{ ErrorStore::Error.new.decompress_gzip({key: 'value'}) }.to raise_exception(ErrorStore::BadData)
    end
  end

  describe 'trim' do
    it 'trims the string to MAX_VARIABLE_SIZE' do
      expect( ErrorStore::Error.new.trim(issue_error.data).length ).to eq(ErrorStore::MAX_VARIABLE_SIZE)
    end
    it 'trims the string to max_size defined' do
      expect( ErrorStore::Error.new.trim(issue_error.data, max_size: 99).length ).to eq(99)
    end

    it 'trims a hash to a max_depth of 3' do
      expect( ErrorStore::Error.new.trim_hash({key: 'value', key1: 'value1', key2: 'value2', key3: 'value3', key4: 'value4',  key5: 'value5'}, max_items: 3).length ).to eq(3)
    end

    it 'trims the hash value strings' do
      #TODO ...
    end

    it 'trims a hash to a max_depth defined' do
      expect( ErrorStore::Error.new.trim_hash({key: 'value', key1: 'value1', key2: 'value2', key3: 'value3', key4: 'value4',  key5: 'value5'}, max_items: 5).length ).to eq(5)
    end
    it 'trims a hash and stops at max_size'

    it 'trims an array and stops at max_size'
    it 'trims the array strings'
  end

  xdescribe 'trim_hash' do
    it 'trims the hash to a number of max_items'
    it 'trims the value of hash'
  end

  xdescribe 'trim_pairs' do
    it 'trims the array of hashes'
    it 'trims the array to a max_items defined'
  end

  xdescribe 'validate_bool' do
    it 'returns true if boolean with true & false'
    it 'returns true if required false and value nil'
    it 'returns true if required false and value is true'
    it 'returns true if required false and value is false'
  end

  describe 'is_url?' do
    it 'is true if filename has file:' do
      expect( ErrorStore::Error.new.is_url?("file://epic/coders.com") ).to be(true)
    end
    it 'is true if filename has http:' do
      expect( ErrorStore::Error.new.is_url?("http://epic-coders.com") ).to be(true)
    end
    it 'is true if filename has https:' do
      expect( ErrorStore::Error.new.is_url?("https://epic-coders.com") ).to be(true)
    end
  end

  xdescribe 'handle_nan' do
    it 'returns <inf> if INFINITY'
    it 'returns <-inf> if -INFINITY'
    it 'returns <nan> if NAN'
    it 'returns value if not float'
  end

  xdescribe 'remove_filename_outliers' do
    it 'removes version numbers v1, 1.0.0 and replaces with <version>'
    it 'removes short sha strings and replaces with <version>'
    it 'removes md5 and replaces with <version>'
    it 'removes sha1 and replaces with <version>'
  end

  xdescribe 'remove_function_outliers' do
    it 'replaces numbers with _<anon>'
  end
end
