require 'rails_helper'

RSpec.describe ErrorStore::Interfaces::Stacktrace do
  xit 'it returns Stacktrace for display_name'
  xit 'it returns type :stacktrace'

  xdescribe 'sanitize_data' do
    it 'raises ValidationError if no frames'
    it 'sets to each frame in_app to false if no has_system_frames'
    it 'sets _data[:frames] to frame_list'
    it 'raises ValidationError if frames_omitted different than 2'
    it 'sets _data[:frames_omitted] to nil if no frames_omitted'
    it 'sets has_system_frames to true if has_system_frames'
    it 'sets has_system_frames to false if no has_system_frames'
    it 'returns a Stacktrace instance'
  end

  xdescribe 'to_json' do
    it 'returns frames, frames_omitted and has_system_frames as hash'
  end

  xdescribe 'slim_frame_data' do
    it 'returns nil if frames_len <= frame_allowance'
    it 'removes vars, pre_context and post_context from frames'
  end

  xdescribe 'get_culprit_string' do
    it 'returns nil if no frames'
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

  xdescribe 'get_hash' do
    it 'returns [] if stack_invalid'
    it 'returns [] if no frames'
    it 'returns no system_frames if set to false'
  end
end
