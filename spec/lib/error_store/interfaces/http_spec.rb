require 'rails_helper'

RSpec.describe ErrorStore::Interfaces::Http do
  let(:website) { create :website }
  let(:group) { create :grouped_issue, website: website }
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_error) { create :issue, subscriber: subscriber, group: group, event_id: '8af060b2986f5914764d49b7f39b036c' }

  let(:request) { post_error_request(website.app_key, website.app_secret, web_response_factory('ruby_exception')) }
  let(:data) { JSON.parse(issue_error.data, symbolize_names: true) }
  let(:error) { ErrorStore::Error.new(request: request, issue: issue_error) }

  it 'it returns HTTP for display_name' do
    expect( ErrorStore::Interfaces::Http.display_name ).to eq("HTTP")
  end
  it 'it returns type :http' do
    expect( ErrorStore::Interfaces::Http.new(error).type ).to eq(:http)
  end

  describe 'sanitize_data' do
    it 'raises ValidationError if data does not have url'
    it 'raises ValidationError if it has method but not in HTTP_METHODS'
    it 'sets method to upcase'
    it 'sets method to nil if blank'
    it 'sets query_string to blank string if ?'
    it 'sets query_string to query from an url'
    it 'sets query_string to blank string if no query on url'
    it 'sets _data[:fragment] from url'
    it 'sets formatted cookies in _data'
    it 'ads formatted headers in _data'
    it 'ads data to be a to_json if data[:data] is a Hash'
    it 'trims body to max_size MAX_HTTP_BODY_SIZE'
    it 'returns a Http instance'
  end

  xdescribe 'format_headers' do
    it 'returns [] if no value'
    it 'joins values if value is an array'
    it 'sets cookie_header if in value we have cookie'
    it 'builds a result array with hashes'
  end

  xdescribe 'format_cookies' do
    it 'returns {} if value blank?'
    it 'returns a hash from cookie query string'
  end
end
