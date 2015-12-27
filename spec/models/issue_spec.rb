require 'rails_helper'

describe Issue do

  let(:issue) { build(:issue) }

  it "has a valid factory" do
    expect(build(:issue)).to be_valid
  end

  describe "ActiveModel validations" do
    it "is invalid without a description" do
      expect(issue).to validate_presence_of :description
    end

  end

   describe "ActiveRecord associations" do
     it "belongs to subscriber" do
      expect(issue).to belong_to(:subscriber)
     end
   end

end

