require 'rails_helper'

RSpec.describe ErrorStore::Manager do
  let(:website) { create :website }
  let(:post_request) { post_error_request(website.app_key, website.app_secret, web_response_factory('ruby_exception')) }
  let(:get_request) { get_error_request(website.app_key, web_response_factory('js_exception')) }
  let(:validated_post_data) { validated_request(post_request) }
  let(:post_manager) { ErrorStore::Manager.new(validated_post_data) }

  describe 'initialize' do
    it 'assigns data and version' do
      expect( post_manager.instance_variable_get(:@data) ).to eq(validated_post_data)
      expect( post_manager.instance_variable_get(:@version) ).to eq('5')
    end
  end

  describe 'store_error', truncation: true do
    subject { post_manager.store_error }
    it 'saves a new grouped_issue' do
      expect {
        subject
      }.to change(GroupedIssue, :count).by(1)
    end
    it 'saves a new issue' do
      expect {
        subject
      }.to change(Issue, :count).by(1)
    end
    it 'saves a new subscriber' do
      expect {
        subject
      }.to change(Subscriber, :count).by(1)
    end
    it 'saves the provided checksum' do
      validated_post_data[:checksum] = 'sd'
      issue = subject
      expect( issue.group.checksum ).to eq('sd')
    end
    it 'creates hash from fingerprint' do
      validated_post_data[:fingerprint] = ['sd', 'wes']
      issue = subject
      expect( issue.group.checksum ).to eq(post_manager.md5_from_hash(post_manager.get_hashes_from_fingerprint(issue, ['sd', 'wes'])))
    end
    it 'creates a new issue without subscriber' do
      validated_post_data[:interfaces].delete(:user)
      expect {
        subject
      }.to change(Subscriber, :count).by(0)
    end
    it 'does not save issue if it fails twice' do
      allow(Issue).to receive(:transaction).and_raise(PG::TRSerializationFailure).twice
      allow(ErrorStore::Manager).to receive(:retry).once
      expect {
        subject
      }.to raise_error(PG::TRSerializationFailure)
    end
    it 'does not save group_issue if already there' do
      req = post_error_request(website.app_key, website.app_secret, web_response_factory('ruby_exception'))
      data = validated_request(req)
      ErrorStore::Manager.new(data).store_error
      expect {
        subject
      }.to change(GroupedIssue, :count).by(0)
    end
    it 'creates issue with already there group_issue' do
      req = post_error_request(website.app_key, website.app_secret, web_response_factory('ruby_exception'))
      data = validated_request(req)
      ErrorStore::Manager.new(data).store_error
      expect {
        subject
      }.to change(Issue, :count).by(1)
    end
  end

  describe '_save_aggregate' do
    it 'returns the new group'
    it 'returns the existing group by hash/checksum'
    it 'returns is_sample false if group new'
    it 'returns is_sample false if is_regression (resolved group gone unresolved)'
    it 'returns is_sample true if it can_sample'
    it 'creates a new grouped_issue'
  end

  xdescribe 'should_sample' do
    it 'returns false if '
  end
end
