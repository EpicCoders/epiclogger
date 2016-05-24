require 'rails_helper'

describe WebsiteMember do
  let(:website) { create(:website) }
  let(:user) { create(:user) }
  let(:website_member) { build(:website_member, website: website, user: user) }

  it "has a valid factory" do
    expect(build(:website_member)).to be_valid
  end

  describe "ActiveRecord associations" do

    it "belongs_to a website" do
      expect(website_member).to belong_to(:website)
    end

    it "belongs_to a member" do
      expect(website_member).to belong_to(:user)
    end
  end
end
