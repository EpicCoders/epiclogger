require 'rails_helper'

 
describe Subscriber do

  let(:subscriber) { build(:subscriber) }

  it "has a valid factory" do
    expect(build(:subscriber)).to be_valid
  end

  describe "ActiveModel validations" do
    it "is invalid without a name" do 
      expect(subscriber).to validate_presence_of :name
    end 

    it "is invalid without an email" do 
      expect(subscriber).to validate_presence_of :email
    end 

    it "is invalid without a website " do 
      expect(subscriber).to validate_presence_of :website
    end 

    it "is invalid with duplication email" do 
      expect(subscriber).to validate_uniqueness_of :email
    end 
  end

   describe "ActiveRecord associations" do

     it "belongs_to a website" do
      expect(subscriber).to belong_to(:website)
     end

    it "has many errors" do
      expect(subscriber).to have_and_belong_to_many(:issues)
     end

   end

end
