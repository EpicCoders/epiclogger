require 'rails_helper'

RSpec.describe ErrorStore::BaseInterface do
  let(:website) { create :website }
  let(:group) { create :grouped_issue, website: website }
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_error) { create :issue, subscriber: subscriber, group: group, event_id: '8af060b2986f5914764d49b7f39b036c' }

  let(:data) { JSON.parse(issue_error.data, symbolize_names: true) }
  let(:error) { ErrorStore::Error.new(request: post_error_request(website.app_key, website.app_secret, web_response_factory('ruby_exception')), issue: issue_error) }

  describe 'initialize' do
    it 'assigns error' do
      expect( ErrorStore::BaseInterface.new(error).instance_variable_get(:@error).issue ).to eq(issue_error)
    end
    it 'assigns _data' do
      expect( ErrorStore::BaseInterface.new(error).instance_variable_get(:@_data) ).to eq({})
    end
  end

  describe 'name' do
    it 'returns the display_name of the interface' do
      expect( ErrorStore::Interfaces::Exception.new(error).name ).to eq("Exception")
    end
  end

  describe 'type' do
    it 'returns the type of the interface' do
      expect( ErrorStore::Interfaces::Exception.new(error).type ).to eq(:exception)
    end
  end

  xdescribe 'to_json' do
    it 'removes blank or equal to 0 values' do
      expect( ErrorStore::BaseInterface.new(error).to_json ).to eq({})
    end
  end

  xdescribe 'get_hash' do
    it 'returns the hash' do
      expect( ErrorStore::BaseInterface.new(error).get_hash ).to eq([])
    end
  end
end
