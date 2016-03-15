require 'rails_helper'

RSpec.describe ErrorStore::Interfaces::Http do
  let(:website) { create :website }
  let(:group) { create :grouped_issue, website: website }
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_error) { create :issue, subscriber: subscriber, group: group, event_id: '8af060b2986f5914764d49b7f39b036c' }

  let(:request) { post_error_request(website.app_key, website.app_secret, web_response_factory('ruby_exception')) }
  let(:data) { JSON.parse(issue_error.data, symbolize_names: true)[:interfaces][:http] }
  let(:error) { ErrorStore::Error.new(request: request) }
  let(:http) { ErrorStore::Interfaces::Http.new(error) }

  it 'it returns HTTP for display_name' do
    expect( ErrorStore::Interfaces::Http.display_name ).to eq("HTTP")
  end
  it 'it returns type :http' do
    expect( ErrorStore::Interfaces::Http.new(error).type ).to eq(:http)
  end

  describe 'sanitize_data' do
    it 'raises ValidationError if data does not have url' do
      data.delete :url
      expect{ http.sanitize_data(data) }.to raise_exception(ErrorStore::ValidationError)
    end
    it 'raises ValidationError if it has method but not in HTTP_METHODS' do
      data[:method] = ""
      expect{ http.sanitize_data(data) }.to raise_exception(ErrorStore::ValidationError)
    end
    it 'sets method to upcase' do
      data[:method] = "post"
      http.sanitize_data(data)
      expect( http._data[:method] ).to eq("POST")
    end
    it 'sets method to nil if blank' do
      http.sanitize_data(data)
      expect( http._data[:method] ).to be_nil
    end
    it 'sets query_string to blank string if ?' do
      data[:url] = "http://localhost:3000??name=epiclogger"
      http.sanitize_data(data)
      expect( http._data[:query_string] ).to eq("name=epiclogger")
    end
    it 'sets query_string to query from an url' do
      data[:url] = "http://localhost:3000?name=epiclogger"
      http.sanitize_data(data)
      expect( http._data[:query_string] ).to eq("name=epiclogger")
    end
    it 'sets query_string to blank string if no query on url' do
      data[:url] = "http://localhost:3000"
      http.sanitize_data(data)
      expect( http._data[:query_string] ).to eq("")
    end
    it 'sets _data[:fragment] from url' do
      data[:url] = 'http://localhost:3000#fragment'
      http.sanitize_data(data)
      expect( http._data[:fragment] ).to eq("fragment")
    end
    # it 'sets formatted cookies in _data' do
    #   result = http.format_cookies(http.format_headers(data[:headers]))
    #   # NoMethodError: undefined method encode for {:host=>"localhost:3001"}:Hash
    #   http.sanitize_data(data)
    #   expect( http._data[:cookies] ).to eq(result)
    # end
    # it 'ads formatted headers in _data' do
    #   http.sanitize_data(data)
    #   expect( http._data[:headers] ).to eq(error.trim_pairs(http.format_headers(data[:headers])))
    #   # NoMethodError: undefined method first for nil:NilClass
    # end
    it 'ads data to be a to_json if data[:data] is a Hash' do
      data[:data] = { :key => 'value' }
      http.sanitize_data(data)
      expect( http._data[:data] ).to eq(data[:data].to_json)
    end
    it 'trims body to max_size MAX_HTTP_BODY_SIZE' do
      data[:data] = issue_error.data * 10
      http.sanitize_data(data)
      expect( http._data[:data].length ).to eq(ErrorStore::MAX_HTTP_BODY_SIZE)
    end
    it 'returns a Http instance' do
      http.sanitize_data(data)
      expect( http.kind_of?(ErrorStore::Interfaces::Http) ).to be(true)
    end
  end

  describe 'format_headers' do
    it 'returns [] if no value' do
      value = {}
      expect( http.format_headers(value) ).to eq([])
    end
    it 'joins values if value is an array' do
      data[:headers].push(:some_key=>["some_value"])
      expect( http.format_headers(data[:headers]).first[9] ).to eq({:some_key=>"some_value"})
    end
    it 'sets cookie_header if in value we have cookie' do
      data[:headers].push("Cookie"=>["some_value"])
      expect( http.format_headers(data[:headers]).second ).to eq("some_value")
    end
    it 'builds a result array with hashes' do
      expect( http.format_headers(data[:headers]).first.all? {|element| element.is_a?(Hash)} ).to eq(true)
    end
  end

  describe 'format_cookies' do
    it 'returns {} if value blank?' do
      value = {}
      expect( http.format_cookies(value) ).to eq({})
    end
    it 'returns a hash from cookie query string' do
      expect( http.format_cookies("some string") ).to eq([{"some string"=>nil}])
    end
  end
end
