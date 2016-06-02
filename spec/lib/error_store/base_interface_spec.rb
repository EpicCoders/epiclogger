require 'rails_helper'

RSpec.describe ErrorStore::BaseInterface do
  let(:user) { create :user }
  let(:website) { create :website }
  let!(:website_member) { create :website_member, user: user, website: website }
  let(:group) { create :grouped_issue, website: website }
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_error) { create :issue, subscriber: subscriber, group: group, event_id: '8af060b2986f5914764d49b7f39b036c' }

  let(:error) { ErrorStore::Error.new(request: post_error_request(web_response_factory('ruby_exception'), website), issue: issue_error) }

  subject { ErrorStore::BaseInterface.new(error) }

  describe 'initialize' do
    it 'assigns error' do
      expect( subject.instance_variable_get(:@error).issue ).to eq(issue_error)
    end
    it 'assigns _data' do
      expect( subject.instance_variable_get(:@_data) ).to eq({})
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

  describe 'to_json' do
    it 'removes blank or equal to 0 values' do
      subject._data = { something: '', other_stuff: 0, valid: 'yes' }
      expect( subject.to_json ).to eq({valid: 'yes'})
    end
  end

  describe 'get_hash' do
    it 'returns the hash' do
      expect( subject.get_hash ).to eq([])
    end
  end
end
