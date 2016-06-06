require 'rails_helper'

describe Message do
  let(:user) { create(:user) }
  let(:website) { create(:website) }
  let!(:website_member) { create :website_member, website: website, user: user }
  let(:grouped_issue) { build(:grouped_issue, website: website) }
  let!(:issue) { create(:issue, group: grouped_issue) }
  let(:message) { build(:message, issue: issue) }

  it "has a valid factory" do
    expect(build(:message, issue: issue)).to be_valid
  end

  describe "ActiveModel validations" do
    it "is invalid without a content" do
      expect(message).to validate_presence_of :content
    end

    it "is validates length of content " do
      expect(message).to validate_length_of(:content)
    end


    it "is invalid without an error" do
      expect(message).to validate_presence_of :issue
    end

  end

   describe "ActiveRecord associations" do
     it "should belong to an error" do
      expect(message).to belong_to(:issue)
     end
   end

end

