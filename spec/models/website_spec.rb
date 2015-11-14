require 'rails_helper'

describe Website do

  let(:member) { create :member }
  let(:website) { create :website }
  let!(:website_member) { create :website_member, website: website, member: member }

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
  end

   describe "ActiveRecord associations" do
    it "has many subscribers" do
      expect(website).to have_many(:subscribers)
    end

    it "has many members" do
      expect(website).to have_many(:members)
    end

    it "has many members" do
      expect(website).to have_many(:website_members)
    end
   end

   describe 'before create' do
    it 'should add app_key and app_secret to website' do
      website = Website.new(domain: 'domain@example.com', title: 'title for page')
      website.save
      expect(website.app_key).not_to be_nil
      expect(website.app_secret).not_to be_nil
    end
   end
end

