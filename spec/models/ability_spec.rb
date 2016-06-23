require 'rails_helper'

RSpec.describe Ability do
  describe 'User' do
    describe 'abilities' do
      let(:admin){ create :user, role: 1 }
      let(:user) { create :user }
      let(:owner) { create :user }
      let(:website) { create :website }
      let!(:user_website_member_with_user) { create :website_member, website: website, user: user }
      let!(:owner_website_member_with_user) { create :website_member, website: website, user: owner, role: 1 }
      let!(:user_website_member_with_admin) { create :website_member, website: website, user: admin }
      let(:group) { create :grouped_issue, website: website }
      let(:subscriber) { create :subscriber, website: website }
      let(:issue) { create :issue, subscriber: subscriber, group: group }
      let(:message) { create :message, issue: issue }

      context 'as owner of org' do
        subject(:ability){ Ability.new(owner) }

        it { is_expected.to be_able_to(:manage, owner) }
        it { is_expected.not_to be_able_to(:manage, user) }
      end
    end
  end
end
