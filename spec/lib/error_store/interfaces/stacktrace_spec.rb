require 'rails_helper'

RSpec.describe ErrorStore::Interfaces::Stacktrace do
  let(:website) { create :website }
  let(:group) { create :grouped_issue, website: website }
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_error) { create :issue, subscriber: subscriber, group: group, event_id: '8af060b2986f5914764d49b7f39b036c' }

  let(:request) { post_error_request(website.app_key, website.app_secret, web_response_factory('ruby_exception')) }
  let(:data) { JSON.parse(issue_error.data, symbolize_names: true)[:interfaces][:exception][:values][0][:stacktrace] }
  let(:error) { ErrorStore::Error.new(request: request, issue: issue_error) }
  let(:stack) { ErrorStore::Interfaces::Stacktrace.new(error) }

  it 'it returns Stacktrace for display_name' do
    expect( ErrorStore::Interfaces::Stacktrace.display_name ).to eq("Stacktrace")
  end
  it 'it returns type :stacktrace' do
    expect( stack.type ).to eq(:stacktrace)
  end

  describe 'sanitize_data' do
    it 'raises ValidationError if no frames' do
      data.delete :frames
      expect{ stack.sanitize_data(data) }.to raise_exception(ErrorStore::ValidationError)
    end
    it 'sets to each frame in_app to false if no has_system_frames'

    it 'sets _data[:frames] to frame_list'

    it 'raises ValidationError if frames_omitted different than 2' do
      data[:frames_omitted] = [{ :a => 'a'}]
      expect{ stack.sanitize_data(data) }.to raise_exception(ErrorStore::ValidationError)
    end
    it 'sets _data[:frames_omitted] to nil if no frames_omitted' do
      expect( stack.sanitize_data(data).instance_variable_get(:@_data)[:frames_omitted] ).to be_nil
    end
    it 'sets has_system_frames to true if has_system_frames' do
      expect( stack.sanitize_data(data).instance_variable_get(:@_data)[:has_frames] ).to be(true)
    end
    it 'sets has_system_frames to false if no has_system_frames' do
      expect( stack.sanitize_data(data, false).instance_variable_get(:@_data)[:has_frames] ).to be(false)
    end
    it 'returns a Stacktrace instance' do
      expect( stack.kind_of?(ErrorStore::Interfaces::Stacktrace) ).to be(true)
    end
  end

  describe 'to_json' do
    it 'returns frames, frames_omitted and has_system_frames as hash' do
      expect( stack.sanitize_data(data).to_json ).to eq(data)
    end
  end

  describe 'slim_frame_data' do
    it 'returns nil if frames_len <= frame_allowance' do
      expect( stack.sanitize_data(data).slim_frame_data(data) ).to be_nil
    end
    it 'removes vars, pre_context and post_context from frames'
  end

  describe 'get_culprit_string' do
    before{ stack._data = data }
    it 'returns nil if no frames' do
      expect( stack.get_culprit_string ).to be_nil
    end
    context 'frame with in_app true' do
      it 'returns culprit with module'
      it 'returns culprit with filename if module blank'
      it 'returns function as ? if blank'
      it 'returns blank string if fileloc blank'
    end
    context 'no frame with in_app true then get from first frame' do
      it 'returns culprit with module'
      it 'returns culprit with filename if module blank'
      it 'returns function as ? if blank'
      it 'returns blank string if fileloc blank'
    end
  end

  describe 'get_hash' do
    it 'returns [] if stack_invalid'
    it 'returns [] if no frames'
    it 'returns no system_frames if set to false'
  end
end
