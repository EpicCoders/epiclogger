require 'rails_helper'

RSpec.describe ErrorStore::BaseInterface do
  xdescribe 'initialize' do
    it 'assigns error'
    it 'assigns _data'
  end

  xdescribe 'name' do
    it 'returns the display_name of the interface'
  end

  xdescribe 'type' do
    it 'returns the type of the interface'
  end

  xdescribe 'to_json' do
    it 'removes blank or equal to 0 values'
  end

  xdescribe 'get_hash' do
    it 'returns the hash'
  end
end
