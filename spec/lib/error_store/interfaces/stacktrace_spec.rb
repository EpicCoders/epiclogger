require 'rails_helper'

RSpec.describe ErrorStore::Interfaces::Stacktrace do
  let(:website) { create :website }
  let(:post_request) { post_error_request(web_response_factory('ruby_exception'), website) }
  let(:post_data) { validated_request(post_request)[:interfaces][:exception][:values][0][:stacktrace] }
  let(:stacktrace) { ErrorStore::Interfaces::Stacktrace.new(post_data) }

  it 'it returns Stacktrace for display_name' do
    expect( ErrorStore::Interfaces::Stacktrace.display_name ).to eq("Stacktrace")
  end
  it 'it returns type :stacktrace' do
    expect( stacktrace.type ).to eq(:stacktrace)
  end

  describe 'sanitize_data' do
    subject { stacktrace.sanitize_data(post_data) }
    it 'raises ValidationError if no frames' do
      post_data.delete(:frames)
      expect { subject }.to raise_exception(ErrorStore::ValidationError)
    end

    it 'sets _data[:frames] to frame_list' do
      expect( subject._data[:frames] ).to include(an_instance_of(ErrorStore::Interfaces::Frame))
    end

    it 'raises ValidationError if frames_omitted different than 2' do
      post_data[:frames_omitted] = [{ :a => 'a'}]
      expect { subject }.to raise_exception(ErrorStore::ValidationError)
    end
    it 'sets _data[:frames_omitted] to nil if no frames_omitted' do
      expect( subject._data[:frames_omitted] ).to be_nil
    end
    it 'sets has_system_frames to true if has_system_frames' do
      expect( subject._data[:has_frames] ).to be_truthy
    end
    it 'sets has_system_frames to false if no has_system_frames' do
      expect( stacktrace.sanitize_data(post_data, false)._data[:has_frames] ).to be_falsey
    end
    it 'returns a Stacktrace instance' do
      expect( subject ).to be_kind_of(ErrorStore::Interfaces::Stacktrace)
    end
  end

  describe 'to_json' do
    it 'returns frames, frames_omitted and has_system_frames as hash' do
      expect( stacktrace.sanitize_data(post_data).to_json.keys ).to eq([:frames, :frames_omitted, :has_frames])
    end
  end

  describe 'slim_frame_data' do
    it 'returns nil if frames_len <= frame_allowance' do
      expect( stacktrace.slim_frame_data(post_data) ).to be_nil
    end
    it 'removes vars, pre_context and post_context from frames' do
      expect( stacktrace.slim_frame_data(post_data, 2)[:frames].first ).not_to include([:vars, :pre_context, :post_context])
    end
  end

  describe 'get_culprit_string' do
    it 'returns nil if no frames' do
      expect( stacktrace.get_culprit_string ).to be_nil
    end

    it 'returns the last frame culprit string' do
      stacktrace.sanitize_data(post_data)
      expect( stacktrace.get_culprit_string ).to eq('app/controllers/home_controller.rb in /')
    end
  end

  describe 'get_hash' do
    subject { stacktrace.sanitize_data(post_data); stacktrace.get_hash }
    it 'returns [] if stack_invalid' do
      first_frame = post_data[:frames].first
      first_frame[:lineno] = 1
      first_frame[:function] = nil
      first_frame[:abs_path] = 'http://google.com'
      post_data[:frames] = [first_frame]
      expect(subject).to eq([])
    end
    it 'returns [] if no frames' do
      post_data[:frames] = []
      expect(subject).to eq([])
    end
  end
end
