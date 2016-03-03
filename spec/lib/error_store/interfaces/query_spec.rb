require 'rails_helper'

RSpec.describe ErrorStore::Interfaces::Query do
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
