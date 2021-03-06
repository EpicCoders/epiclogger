require 'rails_helper'

RSpec.describe ErrorStore::Manager do
  let(:user) { create :user }
  let(:website) { create :website }
  let!(:website_member) { create :website_member, user: user, website: website }
  let!(:release) { create :release, website: website }
  let(:group) { create :grouped_issue, website: website }
  let(:post_request) { post_error_request(web_response_factory('ruby_exception'), website) }
  let(:get_request) { get_error_request(web_response_factory('js_exception'), website) }
  let(:validated_post_data) { validated_request(post_request) }
  let(:post_manager) { ErrorStore::Manager.new(validated_post_data) }
  let(:interface_hash) {
    {"abs_path": "/real/file/name.html",
      "filename": "file/name.html",
      "pre_context": [
          "line1",
          "line2"
      ],
      "context_line": "line3",
      "lineno": 3,
      "post_context": [
          "line4",
          "line5"
      ]}
    }

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

    it 'saves message from data' do
      expect(subject.message).to eq(validated_post_data[:message])
    end

    context 'when message is not present' do
      before(:each) { validated_post_data.delete(:message) }
      it 'should save message from exception' do
        exception_value = validated_post_data[:interfaces][:exception][:values].first
        expect(ErrorStore::Manager.new(validated_post_data).store_error.message).to eq("#{exception_value[:type]}: #{exception_value[:value]}")
      end
      it 'should save <no message> ' do
        validated_post_data[:interfaces][:exception][:values].first[:type] = ''
        validated_post_data[:interfaces][:exception][:values].first[:value] = ''
        expect(ErrorStore::Manager.new(validated_post_data).store_error.message).to eq('<no message>')
      end
    end

    it 'saves a new release' do
      expect {
        subject
      }.to change(Release, :count).by(1)
    end

    it 'returns last release' do
      post_manager.data.delete(:release)
      error = subject
      expect( error.group.release ).to eq(release)
    end

    it 'has no release' do
      post_manager.data.delete(:release)
      release.destroy
      error = subject

      expect( error.group.release ).to eq(nil)
    end

    it 'saves grouped issue without release' do
      post_manager.data.delete(:release)
      release.destroy
      expect {
        subject
      }.to change(GroupedIssue, :count).by(1)
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
      req = post_error_request(web_response_factory('ruby_exception'), website)
      data = validated_request(req)
      ErrorStore::Manager.new(data).store_error
      expect {
        subject
      }.to change(GroupedIssue, :count).by(0)
    end
    it 'creates issue with already there group_issue' do
      req = post_error_request(web_response_factory('ruby_exception'), website)
      data = validated_request(req)
      ErrorStore::Manager.new(data).store_error
      expect {
        subject
      }.to change(Issue, :count).by(1)
    end
  end

  describe '_save_aggregate' do
    let(:issue) { build :issue, event_id: '8af060b2986f5914764d49b7f39b036c', group: nil }
    let(:group_params) {
      {
        message: issue.message,
        platform: issue.platform,
        culprit: 'app/controllers/home_controller.rb in / at line 5',
        issue_logger: 1,
        level: 'fatal',
        time_spent_total: 0,
        time_spent_count: 0,
        release_id: release.id,
        website: website
      }
    }
    subject { post_manager._save_aggregate(issue, 'somehashhere', **group_params) }
    it 'returns the new group' do
      group, _ = subject
      expect(group).to be_a(GroupedIssue)
    end
    it 'returns the existing group by hash/checksum and website_id' do
      existing_group = create :grouped_issue, website: website, checksum: 'somehashhere'
      group, _ = subject
      expect(GroupedIssue.count).to eq(1)
      expect(group).to be_a(GroupedIssue)
      expect(group).to eq(existing_group)
    end
    it 'creates a new group if a group exists with the same hash but different website_id' do
      existing_group = create :grouped_issue, website: website, checksum: 'somehashhere'
      new_website = create :website
      new_website_member = create :website_member, user: user, website: new_website
      group_params[:website] = new_website
      expect{ subject }.to change{ GroupedIssue.count }.by(1)
      group, _ = subject
      expect(group).to be_a(GroupedIssue)
      expect(group.website).to eq(new_website)
    end
    it 'returns is_sample false if group new' do
      _, is_sample = subject
      expect(is_sample).to be_falsey
    end
    it 'returns is_sample false if is_regression (resolved group gone unresolved)' do
      existing_group = create :grouped_issue, website: website, checksum: 'somehashhere', status: GroupedIssue::RESOLVED
      _, is_sample = subject
      expect(is_sample).to be_falsey
      existing_group.reload
      expect(existing_group.status).to eq(3)
    end
    it 'returns is_sample true if it can_sample' do
      create :grouped_issue, website: website, checksum: 'somehashhere', times_seen: 51
      _, is_sample = subject
      expect(is_sample).to be_truthy
    end
    it 'creates a new grouped_issue' do
      expect {
        subject
      }.to change(GroupedIssue, :count).by(1)
    end
  end

  describe 'should_sample' do
    let(:current_datetime) { Time.now }
    let(:last_seen) { current_datetime - 10.seconds }
    it 'returns true if error happened more than 50 times in 60 seconds' do
      expect(post_manager.should_sample(current_datetime, last_seen, 51)).to be_truthy
    end

    it 'returns false if error happened at multiples of 10 in 360 seconds' do
      expect(post_manager.should_sample(current_datetime, last_seen - 400.seconds, 50)).to be_falsey
      expect(post_manager.should_sample(current_datetime, last_seen - 400.seconds, 20)).to be_falsey
      expect(post_manager.should_sample(current_datetime, last_seen - 400.seconds, 30)).to be_falsey
      expect(post_manager.should_sample(current_datetime, last_seen - 400.seconds, 40)).to be_falsey
      expect(post_manager.should_sample(current_datetime, last_seen - 400.seconds, 60)).to be_falsey
      expect(post_manager.should_sample(current_datetime, last_seen - 400.seconds, 53)).to be_truthy
    end

    it 'returns false if error happened less than 60 seconds ago' do
      expect(post_manager.should_sample(current_datetime, last_seen, 1)).to be_falsey
    end
  end

  describe 'time_limit' do
    it 'returns 1 if the error occurance is bigger than 1 hour' do
      expect(post_manager.time_limit(3700)).to eq(1)
    end

    it 'returns MAX_SAMPLE_TIME if error occurance is lower than 60 seconds (1 min)' do
      expect(post_manager.time_limit(30)).to eq(ErrorStore::MAX_SAMPLE_TIME)
    end
  end

  describe 'count_limit' do
    it 'returns 1 if error occured less than 50 times' do
      expect(post_manager.count_limit(30)).to eq(1)
    end

    it 'returns MAX_SAMPLE_RATE if error occured more than 10 mil times' do
      expect(post_manager.count_limit(10_000_001)).to eq(ErrorStore::MAX_SAMPLE_RATE)
    end
  end

  describe '_process_existing_aggregate' do
    let(:group) { create :grouped_issue, message: 'ZeroDivisionError: divided by 0', website: website }
    let(:issue) { build :issue, message: 'New message', event_id: '8af060b2986f5914764d49b7f39b036c', group: group }
    let(:data) {
      {
        message: issue.message,
        platform: issue.platform,
        culprit: 'app/controllers/home_controller.rb in / at line 5',
        issue_logger: 1,
        level: 'fatal',
        time_spent_total: 0,
        time_spent_count: 0
      }
    }
    subject { post_manager._process_existing_aggregate(group, issue, data) }
    it 'increments the group counters' do
      subject
      expect(group.times_seen).to eq(2)
    end
    it 'changes message if it is different' do
      subject
      group.reload
      expect(group.message).to eq('New message')
    end
    it 'changes last_seen to be the issue date as it is new' do
      expect {
        subject
      }.to change(group, :last_seen)
    end
  end

  describe '_handle_regression' do
    let(:group) { create :grouped_issue, message: 'ZeroDivisionError: divided by 0', status: :resolved, website: website }
    let(:issue) { build :issue, message: 'New message', event_id: '8af060b2986f5914764d49b7f39b036c', group: group }
    subject { post_manager._handle_regression(group, issue) }

    it 'returns nil if group unresolved' do
      group.update_attribute(:status, :unresolved)
      expect(subject).to be_nil
    end
    it 'updates the status of the grouped issue' do
      expect {
        subject
      }.to change(group, :status).to('unresolved')
    end
    it 'updates the active_at and last_seen dates to the issue datetime' do
      subject
      group.reload
      expect(group.active_at.to_i).to eq(issue.datetime.to_i)
      expect(group.last_seen.to_i).to eq(issue.datetime.to_i)
    end
    it 'returns true if it is a regression' do
      expect(subject).to be_truthy
    end
  end

  describe 'generate_culprit' do
    subject { post_manager.generate_culprit(validated_post_data) }
    it 'takes culprit from stacktraces' do
      expect(subject).to eq('app/controllers/home_controller.rb in /')
    end

    it 'takes culprit from http' do
      validated_post_data[:interfaces].delete(:exception)
      expect(subject).to eq('http://localhost:3001/')
    end

    it 'calls get_culprit_string on the stacktrace' do
      expect_any_instance_of(ErrorStore::Interfaces::Stacktrace).to receive(:get_culprit_string)
      subject
    end
  end

  describe '_get_subscriber', truncation: true do
    subject { post_manager._get_subscriber(website, validated_post_data) }
    it 'returns nil if no user data' do
      validated_post_data[:interfaces].delete(:user)
      expect(subject).to be_nil
    end

    it 'returns a subscriber instance' do
      expect(subject).to be_a(Subscriber)
    end

    it 'returns the existing subscriber if it is already there' do
      subscriber = create :subscriber, website: website, identity: 1, email: 'some@email.com'
      expect(subject).to eq(subscriber)
    end
  end

  describe 'get_hash_for_issue', truncation: true do
    let(:issue) { post_manager.store_error }
    subject { post_manager.get_hash_for_issue(issue) }

    it 'returns the first hash data' do
      expect(subject).to eq([interface_hash[:filename], interface_hash[:context_line]])
    end
  end

  describe 'get_hash_for_issue_with_reason', truncation: true do
    let(:issue) { post_manager.store_error }
    subject { post_manager.get_hash_for_issue_with_reason(issue) }

    it 'returns the first interface' do
      expect(subject).to eq([:template, [interface_hash[:filename], interface_hash[:context_line]]])
    end
    it 'returns message if no exception' do
      ErrorStore::INTERFACES.each do |interface|
        validated_post_data[:interfaces].delete interface[0]
      end

      expect(subject).to eq([:message, ['ZeroDivisionError: divided by 0']])
    end
  end

  describe 'get_hashes_from_fingerprint', truncation: true do
    let(:issue) { post_manager.store_error }
    let(:fingerprint) { ['{{ default }}'] }
    subject { post_manager.get_hashes_from_fingerprint(issue, fingerprint) }

    it 'should return hash by fingerprint' do
      expect(subject).to eq([[interface_hash[:filename]], [interface_hash[:context_line]], [nil]])
    end
    it 'returns the hash from fingerprint if not default' do
      fingerprint[0] = 'fingerprint'
      expect(subject).to eq([fingerprint, fingerprint])
    end
  end
end
