require 'rails_helper'

RSpec.describe ErrorStore::Interfaces::Message do
  xit 'it returns Message for display_name'
  xit 'it returns type :message'

  xdescribe 'sanitize_data' do
    it 'raises ValidationError if message is blank'
    it 'trims message to 2048'
    it 'trims params to 1024'
    it 'sets _data[:params] to [] if params nil or does not exist in data'
    it 'assigns the right _data attributes'
    it 'returns Message instance'
  end

  xdescribe 'get_hash' do
    it 'returns array with message'
  end
end
