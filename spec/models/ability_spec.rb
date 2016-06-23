require 'rails_helper'

RSpec.describe Ability do
  describe 'User' do
    describe 'abilities' do
      let(:user) { create :user }
      let(:owner) { create :user }
      let(:website) { create :website }
      let!(:user_website_member_with_user) { create :website_member, website: website, user: user, role: 2 }
      let!(:owner_website_member_with_user) { create :website_member, website: website, user: owner}
      let(:group) { create :grouped_issue, website: website }
      let(:subscriber) { create :subscriber, website: website }
      let(:issue) { create :issue, subscriber: subscriber, group: group }
      let(:message) { create :message, issue: issue }

      shared_examples 'it has abilities' do
        it { is_expected.to be_able_to(:manage, group) }
        it { is_expected.to be_able_to(:create, Website.new) }
        it { is_expected.to be_able_to(:manage, message) }
      end

      context 'as owner of website' do
        subject(:ability){ Ability.new(owner) }

        it { is_expected.to be_able_to(:manage, owner) }
        it { is_expected.not_to be_able_to(:manage, user) }
        it { is_expected.to be_able_to(:manage, website) }
        it { is_expected.to be_able_to(:manage, user_website_member_with_user) }
        it { is_expected.to be_able_to(:manage, owner_website_member_with_user) }
        it { is_expected.to be_able_to(:manage, issue) }
        it { is_expected.to be_able_to(:manage, subscriber) }

        it_behaves_like 'it has abilities'
      end

      context 'as user of website' do
        subject(:ability){ Ability.new(user) }

        it { is_expected.not_to be_able_to(:manage, owner) }
        it { is_expected.to be_able_to(:manage, user) }
        it { is_expected.not_to be_able_to(:manage, website) }
        it { is_expected.not_to be_able_to(:manage, user_website_member_with_user) }
        it { is_expected.not_to be_able_to(:manage, owner_website_member_with_user) }
        it { is_expected.not_to be_able_to([:read, :update], issue) }
        it { is_expected.not_to be_able_to(:manage, subscriber) }

        it { is_expected.to be_able_to(:read, website) }
        it { is_expected.to be_able_to(:read, user_website_member_with_user) }

        it_behaves_like 'it has abilities'
      end
    end
  end
end
