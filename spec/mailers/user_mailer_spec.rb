require "rails_helper"

describe UserMailer do
  let(:user) { create :user, reset_password_token: 'KlQFgx2ckDmJsvnbbj3CRw', confirmed_at: Time.now, confirmation_token: 'vJq2UGPUDBZYcO7RiuxkAw'}
  describe 'reset_password' do
    let(:mail) { described_class.reset_password(user) }

    it 'renders the headers' do
      expect(mail.subject).to eq("Epic Logger reset password")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["admin@epiclogger.com"])
    end

    it 'renders the body' do
      expect(mail.body.parts.first.body.raw_source).to eq("Hello, #{user.name}\nYour username is: #{user.email}.\nTo reset your password, just follow this <a href=\"http://localhost:3000/forgot_password/KlQFgx2ckDmJsvnbbj3CRw\">link</a>.\n\n")
    end
  end

  describe 'email_confimation' do
    let(:unconfirmed_user) { create :user, confirmed_at: nil, confirmation_token: 'vJq2UGPUDBZYcO7RiuxkAw', confirmation_sent_at: Time.now}
    let(:mail) { described_class.email_confirmation(unconfirmed_user) }

    it 'renders the headers' do
      expect(mail.subject).to eq("Epic Logger email confirmation")
      expect(mail.to).to eq([unconfirmed_user.email])
      expect(mail.from).to eq(["admin@epiclogger.com"])
    end

    it 'renders the body' do
      expect(mail.body.parts.first.body.raw_source).to eq("Hi #{user.name},\nThis is an email from Epic Logger.\nFollow the url to confirm youre account: <a href=\"http://localhost:3000/users/#{unconfirmed_user.id}/confirm?token=#{unconfirmed_user.confirmation_token}\">click here</a>.\n\n")
    end
  end

  describe 'member_invitation' do
    let(:website) { create :website }
    let!(:website_member) { create :website_member, user_id: user.id, website_id: website.id }
    let(:invite) { create :invite, website: website, invited_by_id: user.id, token: '4zZrL22B6FtRUOU5CJVVbA' }
    let(:mail) { described_class.member_invitation(invite) }

    it 'renders the headers' do
      expect(mail.subject).to eq("Epic Logger Invite Users")
      expect(mail.to).to eq([invite.email])
      expect(mail.from).to eq(["admin@epiclogger.com"])
    end

    it 'renders the body' do
      invite.update_attributes(token: 'T_egItc1APRI_2ThEXA8FA')
      expect(mail.body.parts.first.body.raw_source).to eq( "Hi,\nYou now have access to #{website.domain} website. The invitation was sent by Test User 1.\nTo accept invitation, just follow this link: <a href=\"http://localhost:3000/invites/#{invite.token}/accept\">accept Invitation</a> and complete the registration form.\n\n")
    end
  end
end