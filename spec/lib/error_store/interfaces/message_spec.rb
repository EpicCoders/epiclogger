require 'rails_helper'

RSpec.describe ErrorStore::Interfaces::Message do
  let(:website) { create :website }
  let(:post_request) { post_error_request(web_response_factory('ruby_exception'), website) }
  let(:post_data) { validated_request(post_request)[:interfaces][:message] }
  let(:message) { ErrorStore::Interfaces::Message.new(post_data) }

  it 'it returns Message for display_name' do
    expect( ErrorStore::Interfaces::Message.display_name ).to eq("Message")
  end
  it 'it returns type :message' do
    expect( message.type ).to eq(:message)
  end

  describe 'sanitize_data' do
    subject { message.sanitize_data(post_data) }
    it 'raises ValidationError if message is blank' do
      post_data.delete :message
      expect { subject }.to raise_exception(ErrorStore::ValidationError)
    end
    it 'trims message to 2048' do
      post_data[:message] = 'sometext' * 2000
      expect( subject._data[:message].length ).to eq(2048)
    end
    it 'trims params to 1024' do
      post_data[:params] = ['param', 'param' * 3000]
      expect( subject._data[:params].join(', ').length ).to eq(1024)
    end

    it 'sets _data[:params] to [] if params nil or does not exist in data' do
      post_data[:params] = nil
      expect( subject._data[:params] ).to eq([])
    end

    it 'assigns the right _data attributes' do
      expect( subject._data[:message] ).to eq('Message with %s')
      expect( subject._data[:params] ).to eq(['this'])
    end

    it 'returns Message instance' do
      expect( subject ).to be_kind_of(ErrorStore::Interfaces::Message)
    end
  end

  describe 'get_hash' do
    it 'returns array with message' do
      message.sanitize_data(post_data)
      expect( message.get_hash ).to eq(['Message with %s'])
    end
  end
end
