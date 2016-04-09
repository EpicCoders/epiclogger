require 'rails_helper'


RSpec.describe User, type: :model do

  let(:user) { build(:user) }

  it "has a valid factory" do
    expect(build(:user)).to be_valid
  end

  describe "ActiveModel validations" do
    it "is invalid without a name" do
      expect(user).to validate_presence_of :name
    end

    it "is invalid without an email" do
      expect(user).to validate_presence_of :email
    end
  end

   describe "ActiveRecord associations" do
     it "has many websites" do
      expect(user).to have_many(:websites)
     end
   end

end

