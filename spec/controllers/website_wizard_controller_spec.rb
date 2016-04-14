require 'rails_helper'

RSpec.describe WebsiteWizardController, type: :controller do
  let(:user) { create :user }
  let(:website) { create :website }
  let(:website_member) { create :website_member, website: website, user: user }
  let(:group) { create :grouped_issue, website: website }
  let(:subscriber) { create :subscriber, website: website }
  let(:issue_error) { create :issue, group: group, website: website, subscriber: subcriber }
  let(:message) { create :message, issue: issue_error }
end
