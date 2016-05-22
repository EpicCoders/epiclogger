require 'rails_helper'

describe Invite do

  let(:website) { create(:website) }
  let(:user) { create(:user) }
  let(:website_member) { build(:website_member, website: website, user: user) }
  let(:invite) { build(:invite) }

  it "has a valid factory" do
    expect(build(:invite)).to be_valid
  end

   describe "ActiveRecord associations" do
     it "belongs to website" do
      expect(invite).to belong_to(:website)
     end
   end

  describe '#create' do
    it 'before create should add token to invite' do
      binding.pry
      expect{
        invite.save
        invite.reload
        }.to change(invite, :token)
    end

    it 'validates email on create' do
      invite = Invite.create(email: 'esad')
      expect( invite.save ).to be false

      expect( invite.errors.full_messages ).to eq(["Email is invalid"])
    end

    it { is_expected.not_to be_an_instance_of(TokenGenerator) }
  end

end

