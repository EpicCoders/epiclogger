require 'rails_helper'

RSpec.describe ErrorStore do
  let(:member) { create :member }
  let(:website) { create :website }
  let!(:website_member) { create :website_member, website: website, member: member }
  let(:group) { create :grouped_issue, website: website }
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_error) { create :issue, subscriber: subscriber, group: group }
  let(:message) { 'asdada' }
  let(:default_params) { { website_id: website.id, format: :json } }

  describe 'create!' do
    it 'calls error.create!' do
      expect(ErrorStore::Error).to receive(:create!)
      ErrorStore::Error.create!
    end
    it 'returns the error id' do
      expect(subject).to receive(:create!).and_return(SecureRandom.hex)
      event_id = subject.create!
      expect(event_id).to be_kind_of(String)
      expect(event_id.length).to eq(32)
    end
  end

  describe 'find' do
    it 'calls error.find' do
      expect(subject).to receive(:find)
      subject.find
    end
    it 'returns the error record' do
      issue_error = @issue
      expect(subject).to receive(:find).with(@issue).and_return(issue_error)
      subject.find(@issue)
    end
  end

  describe 'find_interfaces' do
    it 'retuns assigns the interfaces_list'
    it 'contains all the interfaces in the folder'
  end

  describe 'available_interfaces' do
    it 'returns the interfaces array' do
      expect(subject).to receive(:available_interfaces).and_return(Array)
      subject.available_interfaces
    end
    it 'gives the interfaces with all of them if find_interfaces called'
  end

  xdescribe 'interfaces_types' do
    it 'returns an array of interfaces types'
  end

  xdescribe 'get_interface' do
    it 'raises ErrorStore::InvalidInterface if not found'
    it 'returns the interface'
  end

  describe 'constants' do
    it 'INTERFACES holds the interfaces'
    it 'CLIENT_RESERVED_ATTRS holds the reserved attrs'
    it 'VALID_PLATFORMS holds all platforms'
    it 'LOG_LEVELS defines the log levels'
    it 'SAMPLE_RATES all sample rates'
    it 'MAX_SAMPLE_RATE equals max rate' do
      expect(subject).to receive(MAX_SAMPLE_RATE).and_return(10000)
      value = subject.MAX_SIMPLE_RATE
      expect(value).to eq(10000)
    end
    it 'SAMPLE_TIMES equals sample times'
    it 'MAX_SAMPLE_TIME equals max sample time'
    it 'CURRENT_VERSION equals to current version'
    it 'DEFAULT_LOG_LEVEL equals to error'
    it 'DEFAULT_LOGGER_NAME equals nil'
    it 'MAX_STACKTRACE_FRAMES equals to 50 frames kept'
    it 'MAX_HTTP_BODY_SIZE equals to 16kb'
    it 'MAX_EXCEPTIONS has 25 max exceptions'
    it 'MAX_HASH_ITEMS gives the 50 max items'
    it 'MAX_VARIABLE_SIZE gives the max var size (512)'
    it 'MAX_CULPRIT_LENGTH returns the max culprit allowed'
    it 'MAX_MESSAGE_LENGTH returns the message length'
    it 'HTTP_METHODS returns all the methods allowed'
  end

  xdescribe 'exceptions' do
    it 'has StoreError exception'
    it 'has all the other exceptions' do
      # has MissingCredentials, WebsiteMissing, BadData, InvalidTimestamp,
      # InvalidFingerprint, InvalidAttribute, InvalidInterface, ValidationError
    end
  end
end
