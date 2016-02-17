require 'rails_helper'

RSpec.describe ErrorStore::Interfaces::Template do
  xit 'it returns Template for display_name'
  xit 'it returns type :template'

  xdescribe 'sanitize_data' do
    it 'raises ValidationError if filename, context_line or lineno are blank'
    it 'assigns abs_path trimed to 256'
    it 'assigns filename trimed to 256'
    it 'assigns context_line trimed to 256'
    it 'assigns lineno as int'
    it 'assigns the right _data attributes'
    it 'returns Template instance'
  end

  xdescribe 'get_hash' do
    it 'returns array with filename and context_line'
  end
end
