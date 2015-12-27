require 'rails_helper'

describe Issue do

  let(:issue) { build(:issue) }

  it "has a valid factory" do
    expect(build(:issue)).to be_valid
  end

   describe "ActiveRecord associations" do
     it "belongs to subscriber" do
      expect(issue).to belong_to(:subscriber)
     end
   end

end

