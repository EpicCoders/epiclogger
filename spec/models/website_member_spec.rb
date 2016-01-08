require 'rails_helper'

describe WebsiteMember do
  let(:website) { create(:website) }
  let(:member) { create(:member) }
  let(:website_member) { build(:website_member, website: website, member: member) }

  it "has a valid factory" do
    expect(build(:website_member)).to be_valid
  end

  describe "ActiveRecord associations" do

    it "belongs_to a website" do
      expect(website_member).to belong_to(:website)
    end

    it "belongs_to a member" do
      expect(website_member).to belong_to(:member)
    end
  end

  describe 'before create' do
    it 'should add invitation_token to website_member' do
      website_member = WebsiteMember.new( website_id: website.id, member_id: member.id )
      website_member.save
      expect(website_member.invitation_token).not_to be_nil
    end
   end
end
