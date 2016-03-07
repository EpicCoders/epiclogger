require 'rails_helper'

RSpec.describe ErrorStore::Interfaces::Query do
  let(:website) { create :website }
  let(:group) { create :grouped_issue, website: website }
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_error) { create :issue, subscriber: subscriber, group: group, event_id: '8af060b2986f5914764d49b7f39b036c' }
  let(:request) { post_error_request(website.app_key, website.app_secret, web_response_factory('ruby_exception')) }

  let(:error) { ErrorStore::Error.new(request: request, issue: issue_error) }

  it 'it returns Query for display_name' do
    expect( ErrorStore::Interfaces::Query.display_name ).to eq("Query")
  end
  it 'it returns type :query' do
    expect( ErrorStore::Interfaces::Query.new(error).type ).to eq(:query)
  end

  describe 'sanitize_data' do
    it 'raises ValidationError if query is blank'
    it 'trims query to 1024'
    it 'trims engine to 128'
    it 'assigns the right _data attributes'
    it 'returns Query instance'
  end

  xdescribe 'get_hash' do
    it 'returns array with query'
  end
end
