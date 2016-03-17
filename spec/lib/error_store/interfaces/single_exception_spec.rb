require 'rails_helper'

RSpec.describe ErrorStore::Interfaces::SingleException do
  let(:website) { create :website }
  let(:group) { create :grouped_issue, website: website }
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_error) { create :issue, subscriber: subscriber, group: group, event_id: '8af060b2986f5914764d49b7f39b036c' }

  let(:data) { JSON.parse(issue_error.data, symbolize_names: true)[:interfaces][:exception][:values][0] }
  let(:error) { ErrorStore::Error.new(request: post_error_request(web_response_factory('ruby_exception'), website), issue: issue_error) }
  let(:single_exception) { ErrorStore::Interfaces::SingleException.new(error) }

  it 'it returns Single Exception for display_name' do
    expect( ErrorStore::Interfaces::SingleException.display_name ).to eq("Single Exception")
  end
  it 'it returns type :single_exception' do
    expect( single_exception.type ).to eq(:single_exception)
  end

  describe 'sanitize_data' do
    it 'raises ValidationError if no type or value' do
      data.delete :type
      data.delete :value
      expect{ single_exception.sanitize_data(data, true)}.to raise_exception(ErrorStore::ValidationError)
    end
    it 'assigns _data[:stacktrace] to a new stacktrace' do
      expect_any_instance_of( ErrorStore::Interfaces::Stacktrace ).to receive(:sanitize_data)
      single_exception.sanitize_data(data)
    end
    it 'trims type to 128 chars' do
      data[:type] = issue_error.data
      expect( single_exception.sanitize_data(data, true).instance_variable_get(:@_data)[:type].length ).to eq(128)
    end
    it 'trims value to 4096 chars' do
      data[:value] = issue_error.data
      expect( single_exception.sanitize_data(data, true).instance_variable_get(:@_data)[:value].length ).to eq(4096)
    end
    it 'trims module to 128 chars' do
      data[:module] = issue_error.data
      expect( single_exception.sanitize_data(data, true).instance_variable_get(:@_data)[:module].length ).to eq(128)
    end
    it 'returns a SingleException instance' do
      expect( single_exception.kind_of?(ErrorStore::Interfaces::SingleException) ).to be(true)
    end
  end

  describe 'to_json' do
    before{ single_exception._data = data }

    it 'returns stacktrace to_json data' do
      expect( single_exception.to_json[:stacktrace] ).to eq( data[:stacktrace].to_json)
    end
    it 'returns stacktrace as nil if no stacktrace' do
      single_exception._data[:stacktrace] = nil
      expect( single_exception.to_json[:stacktrace] ).to be_nil
    end
    it 'returns type, value, module, stacktrace' do
      expect( single_exception.to_json ).to eq({:type=>data[:type], :value=>data[:value], :module=>data[:module], :stacktrace=>data[:stacktrace].to_json})
    end
  end

  describe 'get_hash' do
    before{ single_exception._data = data }

    it 'returns array of type and value if no stacktrace' do
      single_exception._data.delete :stacktrace
      expect( single_exception.get_hash.include?(data[:type] && data[:value]) ).to be(true)
    end
    it 'returns stacktrace and type array'
  end
end
