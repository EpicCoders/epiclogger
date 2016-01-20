require 'rails_helper'

RSpec.describe ErrorStore::Utils do
  xdescribe 'is_numeric?' do
    it 'returns true for numeric'
    it 'returns false for chars'
    it 'does not care if string or int it works'
  end

  xdescribe 'decode_json' do
    it 'parses valid json with symbolize_names'
    it 'raises BadData if invalid json'
  end

  xdescribe 'decode_and_decompress' do
    it 'does inflate of base64 data'
    it 'does base64.decode if zlib error'
    it 'raises BadData if invalid'
  end

  xdescribe 'decompress_deflate' do
    it 'does inflate of data'
    it 'raises BadData if invalid'
  end

  xdescribe 'decompress_gzip' do
    it 'does GzipReader on data'
    it 'raises BadData if invalid'
  end

  xdescribe 'trim' do
    it 'trims the string to MAX_VARIABLE_SIZE'
    it 'trims the string to max_size defined'

    it 'trims a hash to a max_depth of 3'
    it 'trims the hash value strings'
    it 'trims a hash to a max_depth defined'
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

  xdescribe 'is_url?' do
    it 'is true if filename has file:'
    it 'is true if filename has http:'
    it 'is true if filename has https:'
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
