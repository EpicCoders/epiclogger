require 'rails_helper'

RSpec.describe ErrorStore::Interfaces::SingleException do
  xit 'it returns Single Exception for display_name'
  xit 'it returns type :single_exception'

  xdescribe 'sanitize_data' do
    it 'raises ValidationError if no type or value'
    it 'assigns _data[:stacktrace] to a new stacktrace'
    it 'trims type to 128 chars'
    it 'trims value to 4096 chars'
    it 'trims module to 128 chars'
    it 'returns a SingleException instance'
  end

  xdescribe 'to_json' do
    it 'returns stacktrace to_json data'
    it 'returns stacktrace as nil if no stacktrace'
    it 'returns type, value, module, stacktrace'
  end

  xdescribe 'get_hash' do
    it 'returns array of type and value if no stacktrace'
    it 'returns stacktrace and type array'
  end
end
