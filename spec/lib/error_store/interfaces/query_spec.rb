require 'rails_helper'

RSpec.describe ErrorStore::Interfaces::Query do
  let(:website) { create :website }
  let(:post_request) { post_error_request(web_response_factory('ruby_exception'), website) }
  let(:post_data) { validated_request(post_request)[:interfaces][:query] }
  let(:query) { ErrorStore::Interfaces::Query.new(post_data) }

  it 'it returns Query for display_name' do
    expect( ErrorStore::Interfaces::Query.display_name ).to eq("Query")
  end
  it 'it returns type :query' do
    expect( query.type ).to eq(:query)
  end

  describe 'sanitize_data' do
    subject { query.sanitize_data(post_data) }
    it 'raises ValidationError if query is blank' do
      post_data[:query] = nil
      expect { subject }.to raise_error(ErrorStore::ValidationError, 'No "query" present')
    end
    it 'trims query to 1024' do
      post_data[:query] = 'SELECT 1' * 1000
      expect( subject._data[:query].length ).to eq(1024)
    end
    it 'trims engine to 128' do
      post_data[:engine] = 'postgresql' * 200
      expect( subject._data[:engine].length ).to eq(128)
    end
    it 'assigns the right _data attributes' do
      expect( subject._data.keys ).to eq([:query, :engine])
    end
    it 'returns Query instance' do
      expect( subject ).to be_kind_of(ErrorStore::Interfaces::Query)
    end
  end

  describe 'get_hash' do
    it 'returns array with query' do
      query.sanitize_data(post_data)
      expect( query.get_hash ).to eq([post_data[:query]])
    end
  end
end
