require 'rails_helper'

RSpec.describe Ability do
  describe 'User' do
    describe 'abilities' do
      let(:admin){ create :user, role: 1 }
      let(:user) { create :user }
      let(:website) { create :website }
      let!(:user_website_member_with_user) { create :website_member, website: website, user: user }
      let!(:owner_website_member_with_user) { create :website_member, website: website, user: user, role: 1 }
      let!(:user_website_member_with_admin) { create :website_member, website: website, user: admin }
      let!(:owner_website_member_with_admin) { create :website_member, website: website, user: admin, role: 1 }
      let(:group) { create :grouped_issue, website: website }
      let(:subscriber) { create :subscriber, website: website }
      let(:issue) { create :issue, subscriber: subscriber, group: group }
      let(:message) { create :message, issue: issue }

      context 'admin' do
        let(:ability){ Ability.new(admin) }

        it 'can manage' do
          assert ability.can?(:manage, admin)
          assert ability.can?(:manage, website)
          assert ability.can?(:manage, user_website_member_with_admin)
          assert ability.can?(:manage, owner_website_member_with_admin)
          assert ability.can?(:manage, group)
          assert ability.can?(:manage, subscriber)
          assert ability.can?(:manage, issue)
          assert ability.can?(:manage, message)
        end
      end
    end
  end
end
