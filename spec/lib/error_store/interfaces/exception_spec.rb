require 'rails_helper'

RSpec.describe ErrorStore::Interfaces::Exception do
  xit 'it returns Exception for display_name'
  xit 'it returns type :exception'

  xdescribe 'sanitize_data' do
    it 'sets _data to be a hash with values and array of data'
    it 'raises ValidationError if no data[:values]'
    it 'trims values to not go with too many exceptions'
    it 'checks [:values][:stacktrace] and calls SingleException with has_frames'
    it 'checks [:values][:stacktrace] and calls SingleException without has_frames'
    it 'sets _data[:values] to eq SingleExceptions'
    it 'raises ValidationError if data[:exc_omitted].length is equal to 2'
    it 'returns Exception instance'
  end

  xdescribe 'to_json' do
    it 'returns a hash of values and exc_omitted'
  end

  xdescribe 'data_has_frames' do
    it 'returns true if it has frames'
    it 'returns false if it does not have frames'
  end

  xdescribe 'trim_exceptions' do
    it 'trims exceptions to max'
  end

  xdescribe 'get_hash' do
    it 'returns system_hash'
    it 'returns system_hash'
  end
end
