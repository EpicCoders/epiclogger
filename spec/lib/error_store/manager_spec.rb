# require 'rails_helper'

# RSpec.describe ErrorStore::Manager do
#   let(:website) { create :website }
#   let(:group) { create :grouped_issue, website: website }
#   let(:subscriber) { create :subscriber, website: website }
#   let!(:issue_error) { create :issue, subscriber: subscriber, group: group }
#   let(:request) { post_error_request(website.app_key, website.app_secret, web_response_factory('ruby_exception')) }
#   let(:data) { JSON.parse(web_response_factory('ruby_exception'), symbolize_names: true) }
#   let(:args) { {:message=>"ZeroDivisionError: divided by 0", :platform=>"ruby", :culprit=>"app/controllers/home_controller.rb in / at line 5", :issue_logger=>"", :level=>40, :last_seen=>"2016-02-17T12:29:56", :first_seen=>"2016-02-17T12:29:56", :time_spent_total=>2, :time_spent_count=>1} }
#   describe 'initialize' do
#     it 'assigns data and version' do
#       expect( ErrorStore::Manager.new(data).instance_variable_get(:@data) ).to eq(data)
#       expect( ErrorStore::Manager.new(data).instance_variable_get(:@version) ).to eq("5")
#     end
#   end

#   describe 'store_error' do
#     it 'saves the provided checksum', truncation: true do
#       optional_website = create :website, id:1, domain: "http://random-domain.com", title: "Title"
#       expect( ErrorStore::Manager.new(data).store_error.group.checksum ).to eq((Digest::MD5.new.update issue_error.message).hexdigest)
#     end
#     it 'creates hash from fingerprint'
#     it 'creates a new issue without subscriber', truncation: true do
#       expect( ErrorStore::Manager.new(data).store_error.subscriber ).to be_nil
#     end
#     it 'creates a new issue with subscriber'
#     it 'creates issue if it fails once'
#     it 'does not save issue if it fails twice'
#     it 'saves group_issue if new', truncation: true do
#       data[:message] = 'new message'
#       expect{ ErrorStore::Manager.new(data).store_error }.to change(GroupedIssue, :count).by(1)
#     end
#     it 'does not save group_issue if already there', truncation: true do
#       expect{ ErrorStore::Manager.new(data).store_error }.to change(GroupedIssue, :count).by(0)
#     end
#     it 'creates issue with already there group_issue'
#   end

#   describe '_save_aggregate' do
#     it 'returns the new group' do
#       expect( ErrorStore::Manager.new(data)._save_aggregate(issue_error, "rand", args)[0].new_record? ).to be(true)
#     end
#     it 'returns the existing group by hash/checksum' do
#     end
#     it 'returns is_sample false if group new'
#     it 'returns is_sample false if is_regression (resolved group gone unresolved)'
#     it 'returns is_sample true if it can_sample'
#     it 'creates a new grouped_issue'
#   end

#   xdescribe 'should_sample' do
#     it 'returns false if '
#   end
# end
