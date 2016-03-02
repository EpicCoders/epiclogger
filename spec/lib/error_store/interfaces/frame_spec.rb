require 'rails_helper'

RSpec.describe ErrorStore::Interfaces::Frame do
  let(:website) { create :website }
  let(:group) { create :grouped_issue, website: website }
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_error) { create :issue, subscriber: subscriber, group: group, event_id: '8af060b2986f5914764d49b7f39b036c' }

  let(:request) { post_error_request(website.app_key, website.app_secret, web_response_factory('ruby_exception')) }
  let(:data) { JSON.parse(issue_error.data, symbolize_names: true) }
  let(:error) { ErrorStore::Error.new(request: request, issue: issue_error) }

  it 'it returns Frame for display_name' do
    expect( ErrorStore::Interfaces::Frame.display_name ).to eq("Frame")
  end
  it 'it returns type :frame' do
    expect( ErrorStore::Interfaces::Frame.new(error).type ).to eq(:frame)
  end

  xdescribe 'sanitize_data' do
    context 'raises ValidationError' do
      it 'if abs_path is not string'
      it 'if filename is not string'
      it 'if function is not string'
      it 'if module is not string'
      it 'if no filename function or errmodule'
    end

    it 'sets abs_path to filename if empty and filename to nil'
    it 'sets filename to abs_path.path if url'

    it 'sets function to nil if function equals ?'

    it 'sets context_locals to hash if array'
    it 'sets context_locals to empty hash if not Hash'
    it 'trimps hash of context_locals'

    it 'sets data to a hash of data[:data]'

    it 'trims context_line to max_size 256'

    it 'sets pre_context elements to empty string instead of nil'
    it 'sets post_context elements to empty string instead of nil'
    it 'sets pre_context and post_context to nil if context_line is blank'

    it 'sets lineno to number'
    it 'sets lineno to nil if lower than 0'

    it 'sets colno to number'
    it 'returns a Frame instance'
  end

  xdescribe 'get_culprit_string' do
    it 'returns culprit with module'
    it 'returns culprit with filename if module blank'
    it 'returns function as ? if blank'
    it 'returns blank string if fileloc blank'
  end

  xdescribe 'get_hash' do
    it 'contains the module'
    it 'has filename'
    it 'has filename without outliers'
    it 'does not have context_line if context_line nil'
    it 'does not have context_line if context_line length > 120'
    it 'does not have context_line if no function and path_url?'
    it 'has context_line if function provided'
    it 'has context_line if no function'
    it 'returns output if no !output and !can_use_context'
    it 'has function if function is_unhashable_function'
    it 'has function if function'
    it 'has lineno'
  end

  xdescribe 'is_unhashable_module' do
    it 'returns true if module include Lambda'
    it 'returns false if module does not include Lambda'
  end

  xdescribe 'is_unhashable_function' do
    it 'returns true if function starts with lambda'
    it 'returns true if function starts with Anonymous'
    it 'returns false if function does not have lambda or Anonymous'
  end

  xdescribe 'is_caused_by?' do
    it 'returns true if filename starts with Caused by:'
    it 'returns false if filename it does not start with Caused by:'
  end

  xdescribe 'path_url?' do
    it 'returns true if abs_path is an url'
    it 'returns false if no abs_path'
    it 'returns false if abs_path is not an url'
  end
end
