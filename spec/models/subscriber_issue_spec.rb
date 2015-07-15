require 'rails_helper'

describe SubscriberIssue do

  let(:subscriber_issue) { build(:subscriber_issue) }

  it "has a valid factory" do
    expect(build(:subscriber_issue)).to be_valid
  end

  describe "ActiveModel validations" do
    it "is invalid without a subscriber" do 
      expect(subscriber_issue).to validate_presence_of :subscriber
    end 

    it "is invalid without an issue" do 
      expect(subscriber_issue).to validate_presence_of :issue
    end 
  end

   describe "ActiveRecord associations" do
     it "belongs to subscriber" do
      expect(subscriber_issue).to belong_to(:subscriber)
     end

     it "belongs to issue" do
      expect(subscriber_issue).to belong_to(:issue)
     end
   end

end

