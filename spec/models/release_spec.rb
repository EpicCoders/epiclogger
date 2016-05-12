require 'rails_helper'

describe Message do
  let(:user) { create(:user) }
  let(:website) { create(:website) }
  let!(:website_member) { create :website_member, website: website, user: user }
  let(:release) { build(:release, website: website) }

  it "has a valid factory" do
    expect(build(:release)).to be_valid
  end

   describe "ActiveRecord associations" do
     it "should belong to an website" do
      expect(release).to belong_to(:website)
     end
   end

end

