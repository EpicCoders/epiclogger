require 'rails_helper'

RSpec.describe ErrorStore::Interfaces::Exception do
  let(:website) { create :website }
  let(:post_request) { post_error_request(web_response_factory('ruby_exception'), website) }
  let(:post_data) { validated_request(post_request)[:interfaces][:exception] }
  let(:exception) { ErrorStore::Interfaces::Exception.new(post_data) }

  it 'it returns Exception for display_name' do
    expect( ErrorStore::Interfaces::Exception.display_name ).to eq("Exception")
  end
  it 'it returns type :exception' do
    expect( exception.type ).to eq(:exception)
  end

  describe 'sanitize_data' do
    subject { exception.sanitize_data(post_data) }
    it 'sets _data to be a hash with values and array of data' do
      expect( subject._data ).to be_kind_of(Hash)
      expect( subject._data[:values] ).to be_kind_of(Array)
    end
    it 'raises ValidationError if no data[:values]' do
      post_data[:values] = nil
      expect{ subject }.to raise_exception(ErrorStore::ValidationError, 'No "values" present')
    end
    it 'checks [:values][:stacktrace] and calls SingleException with has_frames' do
      expect_any_instance_of(ErrorStore::Interfaces::SingleException).to receive(:sanitize_data).with(post_data[:values][0], true).and_return(post_data[:values][0])
      subject
    end
    it 'checks [:values][:stacktrace] and calls SingleException without has_frames' do
      post_data[:values][0][:stacktrace][:frames] = []
      expect_any_instance_of(ErrorStore::Interfaces::SingleException).to receive(:sanitize_data).with(post_data[:values][0], false)
      subject
    end
    it 'sets _data[:values] to eq SingleExceptions' do
      expect( subject._data[:values][0] ).to be_kind_of(ErrorStore::Interfaces::SingleException)
    end
    it 'raises ValidationError if data[:exc_omitted].length is equal to 2' do
      post_data[:exc_omitted] = { :a => 'a', :b => 'b', :c => 'c' }
      expect{ subject }.to raise_exception(ErrorStore::ValidationError)
    end
    it 'returns Exception instance' do
      expect( subject ).to be_kind_of(ErrorStore::Interfaces::Exception)
    end
  end

  describe 'to_json' do
    subject { exception.sanitize_data(post_data); exception.to_json }
    it 'has values' do
      expect( subject.keys ).to include(:values)
    end

    it 'has exc_omitted' do
      expect( subject.keys ).to include(:exc_omitted)
    end
  end

  describe 'data_has_frames' do
    subject { exception.data_has_frames(post_data) }
    it 'returns true if it has frames' do
      expect( subject ).to be(true)
    end
    it 'returns false if it does not have frames' do
      post_data[:values][0][:stacktrace][:frames] = []
      expect( subject ).to be(false)
    end
  end

  describe 'get_hash' do
    subject { exception.sanitize_data(post_data); exception.get_hash }
    it 'returns types of stacktrace' do
      expect( subject ).to include(:single_exception)
    end

    it 'contains stacktrace hash with filename' do
      expect( subject ).to include(post_data[:values][0][:stacktrace][:frames][0][:filename])
    end
  end
end
