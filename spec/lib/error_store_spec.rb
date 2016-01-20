require 'rails_helper'

RSpec.describe ErrorStore do
  xdescribe 'create!' do
    it 'calls error.create!'
    it 'returns the error id'
  end

  xdescribe 'find' do
    it 'calls error.find'
    it 'returns the error record'
  end

  xdescribe 'find_interfaces' do
    it 'retuns assigns the interfaces_list'
    it 'contains all the interfaces in the folder'
  end

  xdescribe 'available_interfaces' do
    it 'returns the interfaces array'
    it 'gives the interfaces with all of them if find_interfaces called'
  end

  xdescribe 'interfaces_types' do
    it 'returns an array of interfaces types'
  end

  xdescribe 'get_interface' do
    it 'raises ErrorStore::InvalidInterface if not found'
    it 'returns the interface'
  end

  xdescribe 'constants' do
    it 'INTERFACES holds the interfaces'
    it 'CLIENT_RESERVED_ATTRS holds the reserved attrs'
    it 'VALID_PLATFORMS holds all platforms'
    it 'LOG_LEVELS defines the log levels'
    it 'SAMPLE_RATES all sample rates'
    it 'MAX_SAMPLE_RATE equals max rate'
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
