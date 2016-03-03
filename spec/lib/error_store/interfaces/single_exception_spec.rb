require 'rails_helper'

RSpec.describe ErrorStore::Interfaces::SingleException do
  let(:website) { create :website }
  let(:group) { create :grouped_issue, website: website }
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_error) { create :issue, subscriber: subscriber, group: group, event_id: '8af060b2986f5914764d49b7f39b036c' }

  let(:data) { JSON.parse(issue_error.data, symbolize_names: true) }
  let(:error) { ErrorStore::Error.new(request: post_error_request(website.app_key, website.app_secret, web_response_factory('ruby_exception')), issue: issue_error) }

  it 'it returns Single Exception for display_name' do
    expect( ErrorStore::Interfaces::SingleException.display_name ).to eq("Single Exception")
  end
  it 'it returns type :single_exception' do
    expect( ErrorStore::Interfaces::SingleException.new(error).type ).to eq(:single_exception)
  end

  describe 'sanitize_data' do
    it 'raises ValidationError if no type or value' do
      data[:interfaces][:exception][:values][0].delete :type
      data[:interfaces][:exception][:values][0].delete :value
      expect{ ErrorStore::Interfaces::SingleException.new(error).sanitize_data(data[:interfaces][:exception][:values][0], true)}.to raise_exception(ErrorStore::ValidationError)
    end
    it 'assigns _data[:stacktrace] to a new stacktrace' do
      # expect( ErrorStore::Interfaces::SingleException.new(error).sanitize_data(data[:interfaces][:exception][:values][0], true).instance_variable_get(:@_data)[:stacktrace] ).to eq(ErrorStore::Interfaces::Stacktrace.new(error).sanitize_data(data[:interfaces][:exception][:values][0][:stacktrace]))
    end
    it 'trims type to 128 chars' do
      data[:interfaces][:exception][:values][0][:type] = issue_error.data
      expect( ErrorStore::Interfaces::SingleException.new(error).sanitize_data(data[:interfaces][:exception][:values][0], true).instance_variable_get(:@_data)[:type].length ).to eq(128)
    end
    it 'trims value to 4096 chars' do
      data[:interfaces][:exception][:values][0][:value] = issue_error.data
      expect( ErrorStore::Interfaces::SingleException.new(error).sanitize_data(data[:interfaces][:exception][:values][0], true).instance_variable_get(:@_data)[:value].length ).to eq(4096)
    end
    it 'trims module to 128 chars' do
      data[:interfaces][:exception][:values][0][:module] = issue_error.data
      expect( ErrorStore::Interfaces::SingleException.new(error).sanitize_data(data[:interfaces][:exception][:values][0], true).instance_variable_get(:@_data)[:module].length ).to eq(128)
    end
    it 'returns a SingleException instance'
  end

  describe 'to_json' do
    it 'returns stacktrace to_json data' do
    end
    it 'returns stacktrace as nil if no stacktrace'
    it 'returns type, value, module, stacktrace' do
      expect( ErrorStore::Interfaces::SingleException.new(error).to_json ).to eq({:type=>nil, :value=>nil, :module=>nil, :stacktrace=>nil})
    end
  end

  xdescribe 'get_hash' do
    it 'returns array of type and value if no stacktrace'
    it 'returns stacktrace and type array'
  end
end
