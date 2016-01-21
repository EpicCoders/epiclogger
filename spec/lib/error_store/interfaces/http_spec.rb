require 'rails_helper'

RSpec.describe ErrorStore::Interfaces::Http do
  xit 'it returns HTTP for display_name'
  xit 'it returns type :http'

  xdescribe 'sanitize_data' do
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
