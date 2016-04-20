require 'rails_helper'

describe Website do

  let(:user) { create :user }
  let(:website) { create :website }
  let!(:website_member) { create :website_member, website: website, user: user }

  it "has a valid factory" do
    expect(build(:website)).to be_valid
  end

  describe "ActiveModel validations" do
    it "adds http to website" do
      website2 = create :website, domain: "simple-string.com"
      expect(website2.domain).to eq("http://simple-string.com")
    end

    it "returns same if valid" do
      website2 = create :website, domain: "http://valid-website.com"
      website3 = create :website, domain: "https://secured-website.com"
      expect(website2.domain).to eq("http://valid-website.com")
      expect(website3.domain).to eq("https://secured-website.com")
    end

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
      expect(website).to have_many(:users)
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

