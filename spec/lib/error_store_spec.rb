require 'rails_helper'

RSpec.describe ErrorStore do
  let(:website) { create :website }
  let(:group) { create :grouped_issue, website: website }
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_error) { create :issue, subscriber: subscriber, group: group }
  let(:request) { post_error_request(website.app_key, website.app_secret, web_response_factory('ruby_exception')) }

  describe 'create!', truncation: true do
    it 'calls error.create!' do
      expect_any_instance_of(ErrorStore::Error).to receive(:create!)
      subject.create!(request)
    end
    it 'returns the error id' do
      event_id = subject.create!(request)
      expect(event_id).to be_kind_of(String)
      expect(event_id.length).to eq(32)
    end
  end

  describe 'find' do
    it 'calls error.find' do
      expect_any_instance_of(ErrorStore::Error).to receive(:find)
      subject.find(issue_error)
    end
    it 'returns the error record' do
      expect_any_instance_of(ErrorStore::Error).to receive(:find).and_return(issue_error)
      subject.find(issue_error)
    end
  end

  describe 'find_interfaces' do
    it 'contains all the interfaces in the folder' do
      interfaces = subject.find_interfaces
      check = interfaces.map do |i|
        true if i.match(/query|frame|message|exception|stacktrace|template|template|user|single_exception|http/)
      end.uniq
      expect(check).to eq([true])
      expect(interfaces.length).to eq(9)
    end
  end

  describe 'available_interfaces' do
    before { allow(ErrorStore::BaseInterface).to receive(:available).and_return(true) }

    it 'retuns assigns the interfaces_list' do
      # if we don't run the find_interfaces method then it's blank
      expect(subject.available_interfaces).to eq([])
      expect(subject.available_interfaces).to eq(subject.class_variable_get(:@@interfaces_list))
    end

    it 'returns the interfaces array' do
      expect(subject.available_interfaces).to be_kind_of(Array)
      expect(subject.available_interfaces.length).to eq(0)
    end

    it 'gives the interfaces with all of them if find_interfaces called' do
      subject.find_interfaces # we do a find of the interfaces and we should get them set now
      expect(subject.available_interfaces).to be_kind_of(Array)
      expect(subject.available_interfaces.length).to eq(9)
      expect(subject.available_interfaces).to eq(subject.class_variable_get(:@@interfaces_list))
    end
  end

  describe 'interfaces_types' do
    it 'returns an array of interfaces types' do
      allow(ErrorStore::BaseInterface).to receive(:available).and_return(true)
      subject.class_variable_set(:@@interfaces_list, []) # reset the interfaces list
      subject.find_interfaces

      expect(subject.interfaces_types).to eq([:query, :frame, :message, :exception, :stacktrace, :template, :user, :single_exception, :http])
    end
  end

  describe 'get_interface' do
    before do
      allow(ErrorStore::BaseInterface).to receive(:available).and_return(true)
      subject.find_interfaces
    end
    it 'raises ErrorStore::InvalidInterface if not found' do
      expect { subject.get_interface(:random) }.to raise_exception(ErrorStore::InvalidInterface)
    end

    it 'returns the interface' do
      expect(subject.get_interface(:exception)).to eq(ErrorStore::Interfaces::Exception)
    end
  end

  describe 'constants' do
    it 'INTERFACES holds the interfaces' do
      expect(ErrorStore::INTERFACES).to eq(
        {
          :exception=>:exception,
          :logentry=>:message,
          :request=>:http,
          :stacktrace=>:stacktrace,
          :template=>:template,
          :query=>:query,
          :user=>:user,
          :csp=>:csp,
          :http=>:http,
          :"sentry.interfaces.Exception"=>:exception,
          :"sentry.interfaces.Message"=>:message,
          :"sentry.interfaces.Stacktrace"=>:stacktrace,
          :"sentry.interfaces.Template"=>:template,
          :"sentry.interfaces.Query"=>:query,
          :"sentry.interfaces.Http"=>:http,
          :"sentry.interfaces.User"=>:user,
          :"sentry.interfaces.Csp"=>:csp
        }
      )
    end
    it 'CLIENT_RESERVED_ATTRS holds the reserved attrs' do
      expect(ErrorStore::CLIENT_RESERVED_ATTRS).to eq(
        [
          :website,
          :errors,
          :event_id,
          :message,
          :checksum,
          :culprit,
          :fingerprint,
          :level,
          :time_spent,
          :logger,
          :server_name,
          :site,
          :timestamp,
          :extra,
          :modules,
          :tags,
          :platform,
          :release,
          :environment,
          :interfaces
        ]
      )
    end
    it 'VALID_PLATFORMS holds all platforms' do
      expect(ErrorStore::VALID_PLATFORMS).to eq(
        [
          "as3", "c", "cfml", "csharp", "go", "java", "javascript", "node", "objc", "other", "perl", "php", "python", "ruby"
        ]
      )
    end
    it 'LOG_LEVELS defines the log levels' do
      expect(ErrorStore::LOG_LEVELS).to eq({10=>"debug", 20=>"info", 30=>"warning", 40=>"error", 50=>"fatal"})
    end
    it 'SAMPLE_RATES all sample rates' do
      expect(ErrorStore::SAMPLE_RATES).to eq([[50, 1], [1000, 2], [10000, 10], [100000, 50], [1000000, 300], [10000000, 2000]])
    end
    it 'MAX_SAMPLE_RATE equals max rate' do
      expect(ErrorStore::MAX_SAMPLE_RATE).to eq(10000)
    end
    it 'SAMPLE_TIMES equals sample times' do
      expect(ErrorStore::SAMPLE_TIMES).to eq([[3600, 1], [360, 10], [60, 60]])
    end
    it 'MAX_SAMPLE_TIME equals max sample time' do
      expect(ErrorStore::MAX_SAMPLE_TIME).to eq(10000)
    end
    it 'CURRENT_VERSION equals to current version' do
      expect(ErrorStore::CURRENT_VERSION).to eq('5')
    end
    it 'DEFAULT_LOG_LEVEL equals to error' do
      expect(ErrorStore::DEFAULT_LOG_LEVEL).to eq('error')
    end
    it 'DEFAULT_LOGGER_NAME equals nil' do
      expect(ErrorStore::DEFAULT_LOGGER_NAME).to eq('')
    end
    it 'MAX_STACKTRACE_FRAMES equals to 50 frames kept' do
      expect(ErrorStore::MAX_STACKTRACE_FRAMES).to eq(50)
    end
    it 'MAX_HTTP_BODY_SIZE equals to 16kb' do
      expect(ErrorStore::MAX_HTTP_BODY_SIZE).to eq(16384)
    end
    it 'MAX_EXCEPTIONS has 25 max exceptions' do
      expect(ErrorStore::MAX_EXCEPTIONS).to eq(25)
    end
    it 'MAX_HASH_ITEMS gives the 50 max items' do
      expect(ErrorStore::MAX_HASH_ITEMS).to eq(50)
    end
    it 'MAX_VARIABLE_SIZE gives the max var size (512)' do
      expect(ErrorStore::MAX_VARIABLE_SIZE).to eq(512)
    end
    it 'MAX_CULPRIT_LENGTH returns the max culprit allowed' do
      expect(ErrorStore::MAX_CULPRIT_LENGTH).to eq(200)
    end
    it 'MAX_MESSAGE_LENGTH returns the message length' do
      expect(ErrorStore::MAX_MESSAGE_LENGTH).to eq(8192)
    end
    it 'HTTP_METHODS returns all the methods allowed' do
      expect(ErrorStore::HTTP_METHODS).to eq(["GET", "POST", "PUT", "OPTIONS", "HEAD", "DELETE", "TRACE", "CONNECT", "PATCH"])
    end
  end

  describe 'exceptions' do
    it 'has StoreError exception' do
      expect { raise ErrorStore::StoreError }.to raise_error(ErrorStore::StoreError)
    end
    it 'has all the other exceptions' do
      expect { raise ErrorStore::MissingCredentials }.to raise_error(ErrorStore::MissingCredentials)
      expect { raise ErrorStore::WebsiteMissing }.to raise_error(ErrorStore::WebsiteMissing)
      expect { raise ErrorStore::BadData }.to raise_error(ErrorStore::BadData)
      expect { raise ErrorStore::InvalidTimestamp }.to raise_error(ErrorStore::InvalidTimestamp)
      expect { raise ErrorStore::InvalidFingerprint }.to raise_error(ErrorStore::InvalidFingerprint)
      expect { raise ErrorStore::InvalidAttribute }.to raise_error(ErrorStore::InvalidAttribute)
      expect { raise ErrorStore::InvalidInterface }.to raise_error(ErrorStore::InvalidInterface)
      expect { raise ErrorStore::ValidationError }.to raise_error(ErrorStore::ValidationError)
    end
  end
end
