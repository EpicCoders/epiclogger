require 'rails_helper'

describe Website do

  let(:member) { create :member }
  let(:website) { create :website, member: member }

  it "has a valid factory" do
    expect(build(:website)).to be_valid
  end

  describe "ActiveModel validations" do
    it "is invalid without a title" do
      expect(website).to validate_presence_of :title
    end

    it "is invalid without a domain" do
      expect(website).to validate_presence_of :domain
    end

    it "is invalid without a member" do
      expect(website).to validate_presence_of :member
    end
  end

   describe "ActiveRecord associations" do
     it "belongs to member" do
      expect(website).to belong_to(:member)
     end

     it "has many subscribers" do
      expect(website).to have_many(:subscribers)
     end

    it "has many errors" do
      expect(website).to have_many(:issues)
     end
   end

   describe 'before create' do
    it 'should add app_key and app_id to website' do
      website = Website.new(domain: 'domain@example.com', title: 'title for page', member_id: member.id)
      website.save
      expect(website.app_id).not_to be_nil
      expect(website.app_key).not_to be_nil
    end
   end
end

