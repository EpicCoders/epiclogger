require 'rails_helper'

RSpec.describe ErrorStore::Interfaces::Template do
  let(:website) { create :website }
  let(:group) { create :grouped_issue, website: website }
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_error) { create :issue, subscriber: subscriber, group: group, event_id: '8af060b2986f5914764d49b7f39b036c' }

  let(:request) { post_error_request(web_response_factory('ruby_exception'), website) }
  let(:data) { JSON.parse(issue_error.data, symbolize_names: true)[:interfaces][:exception][:values][0][:stacktrace][:frames][0] }
  let(:error) { ErrorStore::Error.new(request: request, issue: issue_error) }

  it 'it returns Template for display_name' do
    expect( ErrorStore::Interfaces::Template.display_name ).to eq("Template")
  end
  it 'it returns type :template' do
    expect( ErrorStore::Interfaces::Template.new(error).type ).to eq(:template)
  end

  describe 'sanitize_data' do
    it 'raises ValidationError if filename, context_line or lineno are blank' do
      data[:filename] = ""
      expect{ ErrorStore::Interfaces::Template.new(error).santize_data(data) }.to raise_exception(ErrorStore::ValidationError)
    end
    it 'assigns abs_path trimed to 256' do
      data[:abs_path] = issue_error.data
      expect( ErrorStore::Interfaces::Template.new(error).santize_data(data).instance_variable_get(:@_data)[:abs_path].length ).to eq(256)
    end
    it 'assigns filename trimed to 256' do
      data[:filename] = issue_error.data
      expect( ErrorStore::Interfaces::Template.new(error).santize_data(data).instance_variable_get(:@_data)[:filename].length ).to eq(256)
    end
    it 'assigns context_line trimed to 256' do
      data[:context_line] = issue_error.data
      expect( ErrorStore::Interfaces::Template.new(error).santize_data(data).instance_variable_get(:@_data)[:context_line].length ).to eq(256)
    end
    it 'assigns lineno as int' do
      expect( ErrorStore::Interfaces::Template.new(error).santize_data(data).instance_variable_get(:@_data)[:lineno].kind_of?(Integer) ).to be(true)
    end
    it 'assigns the right _data attributes' do
      right_data = {
        abs_path: data[:abs_path],
        filename: data[:filename],
        context_line: data[:context_line],
        lineno: data[:lineno],
        pre_context: data[:pre_context],
        post_context: data[:post_context]
      }
      expect( ErrorStore::Interfaces::Template.new(error).santize_data(data).instance_variable_get(:@_data) ).to eq(right_data)
    end
    it 'returns Template instance' do
      expect( ErrorStore::Interfaces::Template.new(error).santize_data(data).kind_of?(ErrorStore::Interfaces::Template) ).to be(true)
    end
  end

  describe 'get_hash' do
    it 'returns array with filename and context_line' do
      expect( ErrorStore::Interfaces::Template.new(data).get_hash ).to eq([nil, nil])
    end
  end
end
