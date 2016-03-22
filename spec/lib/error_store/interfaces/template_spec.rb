require 'rails_helper'

RSpec.describe ErrorStore::Interfaces::Template do
  let(:website) { create :website }
  let(:post_request) { post_error_request(web_response_factory('ruby_exception'), website) }
  let(:post_data) { validated_request(post_request)[:interfaces][:template] }
  let(:template) { ErrorStore::Interfaces::Template.new(post_data) }

  it 'it returns Template for display_name' do
    expect( ErrorStore::Interfaces::Template.display_name ).to eq("Template")
  end
  it 'it returns type :template' do
    expect( template.type ).to eq(:template)
  end

  describe 'sanitize_data' do
    subject { template.sanitize_data(post_data) }
    it 'raises ValidationError if filename, context_line or lineno are blank' do
      post_data[:filename] = ""
      expect{ subject }.to raise_exception(ErrorStore::ValidationError)
    end
    it 'assigns abs_path trimed to 256' do
      post_data[:abs_path] = "abcd/abc" * 40
      expect( subject._data[:abs_path].length ).to eq(256)
    end
    it 'assigns filename trimed to 256' do
      post_data[:filename] = 'file.rb' * 40
      expect( subject._data[:filename].length ).to eq(256)
    end
    it 'assigns context_line trimed to 256' do
      post_data[:context_line] = 'context_line' * 40
      expect( subject._data[:context_line].length ).to eq(256)
    end
    it 'assigns lineno as int' do
      expect( subject._data[:lineno] ).to be_kind_of(Integer)
    end
    it 'assigns the right _data attributes' do
      right_data = {
        abs_path: post_data[:abs_path],
        filename: post_data[:filename],
        context_line: post_data[:context_line],
        lineno: post_data[:lineno],
        pre_context: post_data[:pre_context],
        post_context: post_data[:post_context]
      }
      expect( subject._data ).to eq(right_data)
    end
    it 'returns Template instance' do
      expect( subject.kind_of?(ErrorStore::Interfaces::Template) ).to be(true)
    end
  end

  describe 'get_hash' do
    it 'returns array with filename and context_line' do
      expect( template.sanitize_data(post_data).get_hash ).to eq(['file/name.html', 'line3'])
    end
  end
end
