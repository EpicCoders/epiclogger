require 'rails_helper'

describe Message do
  let(:member) { create(:member) }
  let(:website) { create(:website) }
  let!(:website_member) { create :website_member, website: website, member: member }
  let(:notification) { build(:notification, website: website) }

  it "has a valid factory" do
    expect(build(:notification)).to be_valid
  end

  describe "ActiveRecord associations" do
    it "should belong to an error" do
      expect(notification).to belong_to(:website)
    end
  end
end

