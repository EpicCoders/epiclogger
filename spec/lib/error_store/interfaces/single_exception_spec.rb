require 'rails_helper'

RSpec.describe ErrorStore::Interfaces::SingleException do
  let(:website) { create :website }
  let(:post_request) { post_error_request(web_response_factory('ruby_exception'), website) }
  let(:post_data) { validated_request(post_request)[:interfaces][:exception][:values][0] }
  let(:single_exception) { ErrorStore::Interfaces::SingleException.new(post_data) }

  it 'it returns Single Exception for display_name' do
    expect( ErrorStore::Interfaces::SingleException.display_name ).to eq("Single Exception")
  end
  it 'it returns type :single_exception' do
    expect( single_exception.type ).to eq(:single_exception)
  end

  describe 'sanitize_data' do
    subject { single_exception.sanitize_data(post_data) }
    it 'raises ValidationError if no type or value' do
      post_data.delete :type
      post_data.delete :value
      expect{ subject }.to raise_exception(ErrorStore::ValidationError)
    end
    it 'assigns _data[:stacktrace] to a new stacktrace' do
      expect( subject._data[:stacktrace] ).to be_kind_of(ErrorStore::Interfaces::Stacktrace)
    end
    it 'trims type to 128 chars' do
      post_data[:type] = 'some_long_text' * 100
      expect( subject._data[:type].length ).to eq(128)
    end
    it 'trims value to 4096 chars' do
      post_data[:value] = 'bigger_text' * 3000
      expect( subject._data[:value].length ).to eq(4096)
    end
    it 'trims module to 128 chars' do
      post_data[:module] = 'some_other' * 100
      expect( subject._data[:module].length ).to eq(128)
    end
    it 'returns a SingleException instance' do
      expect( subject ).to be_kind_of(ErrorStore::Interfaces::SingleException)
    end
  end

  describe 'to_json' do
    subject { single_exception.sanitize_data(post_data); single_exception.to_json }

    it 'returns stacktrace to_json data' do
      expect( subject[:stacktrace] ).not_to be_nil
      expect( subject[:stacktrace] ).to be_kind_of(Hash)
    end
    it 'returns stacktrace as nil if no stacktrace' do
      post_data[:stacktrace] = nil
      expect( subject[:stacktrace] ).to be_nil
    end
    it 'returns type, value, module, stacktrace' do
      expect( subject.keys ).to eq([:type, :value, :module, :stacktrace])
    end
  end

  describe 'get_hash' do
    subject { single_exception.sanitize_data(post_data); single_exception.get_hash }

    it 'returns array of type and value if no stacktrace' do
      post_data[:stacktrace] = nil
      expect( subject ).to eq([post_data[:type], post_data[:value]])
    end
    it 'returns stacktrace and type array' do
      expect( subject ).to eq(single_exception._data[:stacktrace].get_hash << post_data[:type])
    end
  end
end
