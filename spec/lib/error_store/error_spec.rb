require 'rails_helper'

RSpec.describe ErrorStore::Error do
  xdescribe 'intialize' do
    it 'assigns request and issue provided'
  end

  xdescribe 'find' do
    it 'assigns the data to the class'
    it 'returns the class with data'
  end

  xdescribe 'create!' do
    it 'assigns context'
    it 'gets the website'
    it 'assigns data validated'
    it 'returns the event_id'
    it 'saves to cache the data with key'
    it 'calls ErrorWorker'
  end

  xdescribe 'get_website' do
    it 'assigns auth'
    it 'raises MissingCredentials if missing api key'
    it 'raises MissingCredentials if missing api secret'
    it 'assigns website to context'
    it 'raises WebsiteMissing if website does not exist with api key'
    it 'raises MissingCredentials if get request and api_secret is different'
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

  xdescribe '_auth' do
    it 'returns the auth assigned'
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

  xdescribe 'process_timestamp' do

  end
end
