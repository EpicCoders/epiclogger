require 'rails_helper'

RSpec.describe ErrorStore::Interfaces::User do
  xit 'it returns User for display_name'
  xit 'it returns type :user'

  xdescribe 'sanitize_data' do
    it 'trims data[:id] to max_size of 128'
    it 'raises ValidationError if data[:email] is invalid'
    it 'trims the email to max_size of 128 if it is too big'
    it 'trims the username to max_size 128'
    it 'raises ValidationError if ip is not valid'
    it 'assigns the right _data attributes'
    it 'returns User instance'
  end

  xdescribe 'get_hash' do
    it 'empty array'
  end
end
