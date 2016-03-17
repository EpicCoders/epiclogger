require 'rails_helper'

RSpec.describe ErrorStore::Utils do
  let(:website) { create :website }
  let(:group) { create :grouped_issue, website: website }
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_error) { create :issue, subscriber: subscriber, group: group }
  let(:request) { post_error_request(web_response_factory('ruby_exception'), website) }
  let(:first_hash) {
    {
      sec: 're',
      sec1: 'la',
      sec3: {
        mo: 'mi',
        bo: 'fa',
        ko: {
          tri: 'lolo',
          fri: 'moko',
          tuy: {
            loko: 'lolo',
            ww: 'wewe'
          }
        }
      }
    }
  }
  let(:hash) {
    {
      key: first_hash,
      key1: 'la',
      key2: {
        so: ['do', 're', 'mi'],
        lo: 'mi'
      },
      key3: ['do', 're', 'mi']
    }
  }
  let(:dummy_class) { Class.new { extend ErrorStore::Utils } }

  describe 'is_numeric?' do
    it 'returns true for numeric' do
      expect(dummy_class.is_numeric?(1)).to eq(true)
    end
    it 'returns false for chars' do
      expect(dummy_class.is_numeric?('random')).to eq(false)
    end
    it 'does not care if string or int it works' do
      expect(dummy_class.is_numeric?('1')).to eq(true)
    end
  end

  describe 'decode_json' do
    it 'parses valid json with symbolize_names' do
      my_json = '{"event_id":"8af0", "message":"ZeroDivisionError", "timestamp":"2016-02-17T12:29:56"}'
      expect(dummy_class.decode_json(my_json)).to eq({event_id: "8af0", message: "ZeroDivisionError", timestamp: "2016-02-17T12:29:56"})
    end
    it 'raises BadData if invalid json' do
      expect { dummy_class.decode_json('random data') }.to raise_exception(ErrorStore::BadData)
    end
  end

  describe 'decode_and_decompress' do
    it 'does inflate of base64 data' do
      encoded_data = StringIO.new(Base64.strict_encode64(Zlib::Deflate.deflate('random_string')))
      expect( dummy_class.decode_and_decompress(encoded_data.read) ).to eq('random_string')
    end
    it 'does base64.decode if zlib error' do
      allow(Zlib::Inflate).to receive(:inflate).and_raise(Zlib::Error)
      expect(Base64).to receive(:decode64).twice.with('string')
      dummy_class.decode_and_decompress('string')
    end
    it 'raises BadData if invalid' do
      expect{ dummy_class.decode_and_decompress({key: 'value'}) }.to raise_exception(ErrorStore::BadData)
    end
  end

  describe 'decompress_deflate' do
    it 'does inflate of data' do
      encoded_data = StringIO.new(Zlib::Deflate.deflate('random_string'))
      expect( dummy_class.decompress_deflate(encoded_data.read) ).to eq('random_string')
    end
    it 'raises BadData if invalid' do
      expect{ dummy_class.decompress_deflate({key: 'value'}) }.to raise_exception(ErrorStore::BadData)
    end
  end

  describe 'decompress_gzip' do
    it 'does GzipReader on data' do
      encoded_data = ActiveSupport::Gzip.compress("random_string")
      expect( dummy_class.decompress_gzip(encoded_data) ).to eq('random_string')
    end
    it 'raises BadData if invalid' do
      expect{ dummy_class.decompress_gzip({key: 'value'}) }.to raise_exception(ErrorStore::BadData)
    end
  end

  describe 'trim' do
    it 'trims the string to MAX_VARIABLE_SIZE' do
      expect( dummy_class.trim(issue_error.data.to_s).length ).to eq(ErrorStore::MAX_VARIABLE_SIZE)
    end

    it 'trims the string to max_size defined' do
      expect( dummy_class.trim('do the string here do it', max_size: 7) ).to eq('do t...')
    end

    it 'trims the hash to max_size defined' do
      expect( dummy_class.trim(issue_error.data, max_size: 99).length ).to eq(99)
    end

    it 'trims a hash to a max_depth of 1' do
      expect( dummy_class.trim(first_hash, max_depth: 1) ).to eq(
        {
          sec: 're',
          sec1: 'la',
          sec3: {
            mo: 'mi',
            bo: 'fa',
            ko: '{:tri=>"lolo", :fri=>"moko", :tuy=>{:loko=>"lolo", :ww=>"wewe"}}'
          }
        }
      )
    end

    it 'trims the hash value strings' do
      expect( dummy_class.trim({string: 'do the string here do it'}, max_size: 7) ).to eq(string: 'do...' )
    end

    it 'trims a hash and stops at max_size' do
      expect( dummy_class.trim(hash, max_size: 3) ).to eq(key: { sec:"..." })
    end

    it 'trims an array elements and stops at max_size' do
      array = ['first', 'some message', 'array string']
      expect( dummy_class.trim(array, max_size: 10).length ).to eq(2)
    end

    it 'trims the array strings' do
      array = ['first', 'some message', 'array string']
      expect( dummy_class.trim(array, max_size: 10) ).to eq(['first', '...'])
    end
  end

  describe 'trim_hash' do
    it 'trims the hash to a number of max_items' do
      expect( dummy_class.trim_hash(hash, max_items: 1).length ).to eq(1)
    end
    it 'trims the value of hash' do
      expect( dummy_class.trim_hash(hash, max_items: 1) ).to eq(key: first_hash)
    end
  end

  describe 'trim_pairs' do
    it 'trims the array of hashes' do
      array_hashes = [{ host: 'localhost:3001' }, { cache_control: 'max-age=0' }, { data: hash }]
      expect( dummy_class.trim_pairs(array_hashes, max_items: 1) ).to eq([{host: 'localhost:3001' }, { cache_control: 'max-age=0' }])
    end
    it 'trims the array to a max_items defined' do
      array_hashes = [{ host: 'localhost:3001' }, { cache_control: 'max-age=0' }, { data: hash }]
      expect( dummy_class.trim_pairs(array_hashes, max_items: 1).length ).to eq(2)
    end
  end

  describe 'validate_bool' do
    it 'returns true if boolean with true & false' do
      expect( dummy_class.validate_bool(true) ).to be_truthy
      expect( dummy_class.validate_bool(false) ).to be_truthy
    end
    it 'returns true if required false and value nil' do
      expect( dummy_class.validate_bool(nil, false) ).to be_truthy
    end
    it 'returns true if required false and value is true' do
      expect( dummy_class.validate_bool(true, false) ).to be_truthy
    end
    it 'returns true if required false and value is false' do
      expect( dummy_class.validate_bool(false, false) ).to be_truthy
    end
  end

  describe 'is_url?' do
    it 'is true if filename has file:' do
      expect( dummy_class.is_url?('file://epic/coders.com') ).to be_truthy
    end
    it 'is true if filename has http:' do
      expect( dummy_class.is_url?('http://epic-coders.com') ).to be_truthy
    end
    it 'is true if filename has https:' do
      expect( dummy_class.is_url?('https://epic-coders.com') ).to be_truthy
    end
    it 'is false if weird url' do
      expect( dummy_class.is_url?('wqeqewqwe') ).to be_falsey
    end
  end

  describe 'handle_nan' do
    it 'returns <inf> if INFINITY' do
      positive_inf = 1.0 / 0
      expect( dummy_class.handle_nan(positive_inf) ).to eq("<inf>")
    end
    it 'returns <-inf> if -INFINITY' do
      negative_inf = -1.0 / 0
      expect( dummy_class.handle_nan(negative_inf) ).to eq("<-inf>")
    end
    it 'returns <nan> if NAN' do
      nan = 0.0 / 0.0
      expect( dummy_class.handle_nan(nan) ).to eq("<nan>")
    end
    it 'returns value if not float' do
      expect( dummy_class.handle_nan(5) ).to eq(5)
    end
  end

  describe 'remove_filename_outliers' do
    it 'removes version numbers v1, 1.0.0 and replaces with <version>' do
      expect( dummy_class.remove_filename_outliers('/ruby-2.2.2/lib/ruby/2.2.0/webrick/httpserver.rb') ).to eq('/ruby-<version>/lib/ruby/<version>/webrick/httpserver.rb')
      expect( dummy_class.remove_filename_outliers('/ruby-v2.2.2.rb') ).to eq('/ruby-<version>.rb')
    end
    it 'removes short sha strings and replaces with <version>' do
      expect( dummy_class.remove_filename_outliers("our/file/is/here/ruby-15ea0bc8.rb") ).to eq('our/file/is/here/ruby-<version>.rb')
    end
    it 'removes md5 and replaces with <version>' do
      expect( dummy_class.remove_filename_outliers("our/file/is/here/ruby-#{Digest::MD5.hexdigest('foobar')}.rb") ).to eq('our/file/is/here/ruby-<version>.rb')
    end
    it 'removes sha1 and replaces with <version>' do
      expect( dummy_class.remove_filename_outliers("our/file/is/here/ruby-#{Digest::SHA1.hexdigest('foobar')}.rb") ).to eq('our/file/is/here/ruby-<version>.rb')
    end
  end

  describe 'remove_function_outliers' do
    it 'replaces numbers with _<anon>' do
      expect( dummy_class.remove_function_outliers("example_122") ).to eq("example_<anon>")
    end

    it 'does not replace one digit numbers with _<anon>' do
      expect( dummy_class.remove_function_outliers("example_2") ).to eq("example_2")
    end
  end
end
