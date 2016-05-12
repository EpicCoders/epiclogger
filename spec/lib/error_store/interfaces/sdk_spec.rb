require 'rails_helper'
include ErrorStore::Utils

RSpec.describe ErrorStore::Interfaces::Sdk do
  let(:website) { create :website }
  let(:post_request) { post_error_request(web_response_factory('python_exception'), website) }
  let(:post_data) { validated_request(post_request)[:interfaces][:sdk] }
  let(:sdk) { ErrorStore::Interfaces::Sdk.new(post_data) }


  it 'it returns Sdk for display_name' do
    expect( ErrorStore::Interfaces::Sdk.display_name ).to eq("Sdk")
  end

  it 'it returns type :sdk' do
    expect( sdk.type ).to eq(:sdk)
  end

  describe 'sanitize_data' do
    subject { sdk.sanitize_data(post_data) }
    context 'raises ValidationError' do
      it 'raises No name value error' do
        post_data.delete :name
        expect { subject }.to raise_exception(ErrorStore::ValidationError, "No 'name' value")
      end

      it 'raises No version value error' do
        post_data.delete :version
        expect { subject }.to raise_exception(ErrorStore::ValidationError, "No 'version' value")
      end
    end

    it 'assigns the trimmed version and name to self._data' do
      expect( subject._data ).to eq( { name: trim(post_data[:name]), version: trim(post_data[:version]) } )
    end
  end
end