require 'rails_helper'


RSpec.describe User, type: :model do

  let(:user) { build(:user, email: 'gravatar@email.com') }
  let(:website) { create :website }
  let!(:website_member) { create :website_member, website: website, user: user }
  let!(:invite) { create :invite, website: website, invited_by_id: user.id }
  it { is_expected.to enumerize(:role).in(:user, :admin).with_default(:user) }

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
      expect(user).to have_many(:websites).through(:website_members)
     end

     it "has many website members" do
      expect(user).to have_many(:website_members)
     end

     it "website member is user dependent" do
      user2 = create :user, email: 'user2@email.me'
      website_member2 = create :website_member, user: user2, website: website
      expect { user2.destroy}.to change {WebsiteMember.count}
     end

     it "has many invites" do
      expect(user).to have_many(:invites)
     end
   end

  describe "is_owner_of?" do
    it 'should return true' do
      expect( user.is_owner_of?(website) ).to be(true)
    end

    it 'should return false' do
      user2 = create :user, email: 'user2@email.me'
      website2 = create :website
      website_member2 = create :website_member, user: user2, website: website2
      expect( user.is_owner_of?(website2) ).to be(false)
    end
  end

  describe "is_member_of?" do
    it 'should return true' do
      user2 = create :user, email: 'basescu@putinescu.com', role: 'user'
      website_member2 = create :website_member, user: user2, website: website
      expect( user2.is_member_of?(website) ).to be(true)
    end

    it 'should return false' do
      user2 = create :user, email: 'user2@email.me'
      website2 = create :website
      website_member2 = create :website_member, user: user2, website: website2
      expect( user.is_member_of?(website2) ).to be(false)
    end
  end

  describe "default_website" do
    it 'returns first' do
      website2 = create :website
      website_member2 = create :website_member, user: user, website: website2

      expect( user.default_website ).to eq(Website.first)
    end
  end

  describe "send_reset_password" do
    it 'should update attributes' do
      expect{
        user.send_reset_password
        user.reload
        }.to change( user, :reset_password_token )
       .and change( user, :reset_password_sent_at)
    end

    it "should email user" do
      mailer = double('UserMailer')
      expect(mailer).to receive(:deliver_later)
      expect(UserMailer).to receive(:reset_password).with(user).and_return(mailer).once

      user.send_reset_password
    end
  end

  describe "gravatar" do
    it 'should return url' do
      expect( user.avatar_url ).to eq("http://gravatar.com/avatar/bd9ce1e303f62efea7abeaae30288a43.png?s=40")
    end

    it 'should downcase' do
      expect( user.avatar_url.match /[[:upper:]]/ ).to be_nil
    end

    it 'should change size' do
      expect( user.avatar_url(25) ).to eq("http://gravatar.com/avatar/bd9ce1e303f62efea7abeaae30288a43.png?s=25")
    end
  end

  describe "confirmed?" do
    it 'returns true' do
      expect( user.confirmed? ).to be(true)
    end

    it 'returns false' do
      user2 = create :user, confirmed_at: nil
      expect( user2.confirmed? ).to be(false)
    end
  end

  describe "confirm" do
    it 'should update attributes' do
      user2 = create :user, confirmation_token: 'bd9ce1e303f62efea7abeaae3', confirmed_at: nil
      expect{
        user2.confirm
        user2.reload
        }.to change( user2, :confirmation_token ).from('bd9ce1e303f62efea7abeaae3')
       .and change( user2, :confirmed_at).from(nil)
    end
  end

  describe "send_confirmation" do
    it 'should update attributes' do
      expect{
        user.send_confirmation
        user.reload
      }.to change( user, :confirmation_token )
       .and change( user, :confirmation_sent_at )
    end

    it "should email user" do
      mailer = double('UserMailer')
      expect(mailer).to receive(:deliver_later)
      expect(UserMailer).to receive(:email_confirmation).with(user).and_return(mailer).once

      user.send_confirmation
    end
  end
end

