require 'rails_helper'

RSpec.describe ErrorStore::Interfaces::Message do
  let(:website) { create :website }
  let(:group) { create :grouped_issue, website: website }
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_error) { create :issue, subscriber: subscriber, group: group, event_id: '8af060b2986f5914764d49b7f39b036c' }

  let(:request) { post_error_request(website.app_key, website.app_secret, web_response_factory('ruby_exception')) }
  let(:data) { JSON.parse(web_response_factory('ruby_exception'), symbolize_names: true)}
  let(:error) { ErrorStore::Error.new(request: request, issue: issue_error) }
  let(:message) { ErrorStore::Interfaces::Message.new(error) }

  it 'it returns Message for displaya_name' do
    expect( ErrorStore::Interfaces::Message.display_name ).to eq("Message")
  end
  it 'it returns type :message' do
    expect( message.type ).to eq(:message)
  end

  describe 'sanitize_data' do
    it 'raises ValidationError if message is blank' do
      data.delete :message
      expect{ message.sanitize_data(data) }.to raise_exception(ErrorStore::ValidationError)
    end
    it 'trims message to 2048' do
      data[:message] = issue_error.data
      expect( message.sanitize_data(data).instance_variable_get(:@_data)[:message].length ).to eq(2048)
    end
    it 'trims params to 1024' do
      data[:params] = issue_error.data
      message.sanitize_data(data)
      expect( message._data[:params].length ).to eq(1024)
    end

    it 'sets _data[:params] to [] if params nil or does not exist in data' do
      expect( message.sanitize_data(data).instance_variable_get(:@_data)[:params] ).to eq([])
    end

    it 'assigns the right _data attributes' do
      data[:params] = {"format"=>:json, "controller"=>"api/v1/store", "action"=>"create", "id"=>"1"}
      message.sanitize_data(data)
      expect( message._data[:message] ).to eq(data[:message])
      expect( message._data[:params] ).to eq(data[:params])
    end

    it 'returns Message instance' do
      expect( message.kind_of?(ErrorStore::Interfaces::Message) ).to be(true)
    end
  end

  describe 'get_hash' do
    it 'returns array with message' do
      message._data[:message] = "message example"
      expect( message.get_hash ).to eq(["message example"])
    end
  end
end
