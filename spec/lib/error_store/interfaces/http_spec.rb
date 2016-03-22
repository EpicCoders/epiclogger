require 'rails_helper'

RSpec.describe ErrorStore::Interfaces::Http do
  let(:website) { create :website }
  let(:post_request) { post_error_request(web_response_factory('ruby_exception'), website) }
  let(:post_data) { validated_request(post_request)[:interfaces][:http] }
  let(:http) { ErrorStore::Interfaces::Http.new(post_data) }

  it 'it returns HTTP for display_name' do
    expect( ErrorStore::Interfaces::Http.display_name ).to eq("HTTP")
  end
  it 'it returns type :http' do
    expect( http.type ).to eq(:http)
  end

  describe 'sanitize_data' do
    subject { http.sanitize_data(post_data) }
    it 'raises ValidationError if data does not have url' do
      post_data.delete :url
      expect { subject }.to raise_exception(ErrorStore::ValidationError, "No value for 'url'")
    end
    it 'raises ValidationError if it has method but not in HTTP_METHODS' do
      post_data[:method] = ''
      expect { subject }.to raise_exception(ErrorStore::ValidationError, "Invalid value for 'method'")
    end
    it 'sets method to upcase' do
      expect( subject._data[:method] ).to eq("GET")
    end
    it 'sets method to nil if blank' do
      post_data.delete :method
      expect( subject._data[:method] ).to be_nil
    end
    it 'sets query_string to blank string if ?' do
      post_data[:query_string] = '?'
      expect( subject._data[:query_string] ).to eq('')
    end
    it 'sets query_string to query from an url' do
      post_data[:url] = 'http://localhost:3000?name=epiclogger'
      expect( subject._data[:query_string] ).to eq('name=epiclogger')
    end
    it 'sets query_string to blank string if no query on url' do
      expect( subject._data[:query_string] ).to eq('')
    end
    it 'sets _data[:fragment] from url' do
      post_data[:url] = 'http://localhost:3000#fragment'
      expect( subject._data[:fragment] ).to eq('fragment')
    end
    it 'sets formatted cookies in _data' do
      expect( subject._data[:cookies] ).to eq(post_data[:cookies])
    end
    it 'ads formatted headers in _data' do
      expect( subject._data[:headers] ).to eq(post_data[:headers])
    end
    it 'ads data to be a to_json if data[:data] is a Hash' do
      post_data[:data] = { key: 'value' }
      expect( subject._data[:data] ).to eq(post_data[:data].to_json)
    end
    it 'trims body to max_size MAX_HTTP_BODY_SIZE' do
      post_data[:data] = 'some data' * 8000
      expect( subject._data[:data].length ).to eq(ErrorStore::MAX_HTTP_BODY_SIZE)
    end
    it 'returns a Http instance' do
      expect( subject ).to be_kind_of(ErrorStore::Interfaces::Http)
    end
  end

  describe 'format_headers' do
    subject { http.format_headers(post_data[:headers]) }
    it 'returns [] if no value' do
      post_data[:headers] = {}
      expect( subject ).to eq([])
    end
    it 'joins values if value is an array' do
      post_data[:headers] = { value: ['something', 'else'] }
      expect( subject ).to eq([[{ value: 'something, else' }], nil])
    end
    it 'sets cookie_header if in value we have cookie' do
      expect( subject.second ).to eq(post_data[:cookie])
    end
    it 'builds a result array with hashes' do
      expect( subject.first.all? {|element| element.is_a?(Hash)} ).to eq(true)
    end
  end

  describe 'format_cookies' do
    subject { http.format_cookies(post_data[:cookies]) }
    it 'returns {} if value blank?' do
      post_data[:cookies] = {}
      expect( subject ).to eq({})
    end
    it 'returns a hash from cookie query string' do
      post_data[:cookies] = {'something' => 'dothat'}
      expect( subject ).to eq([{"something" => "dothat"}])
    end
  end
end
