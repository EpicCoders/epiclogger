require 'rails_helper'

RSpec.describe InvitesController, type: :controller do
  let(:user) { create :user }
  let(:website) { create :website }
  let!(:website_member) { create :website_member, user_id: user.id, website_id: website.id }
  letget_with user, :show, params(:invite) { create :invite, website: website, invited_by_id: user.id }
  let(:default_params) { { format: :json} }

  before(:each) do session[:epiclogger_website_id] = website.id end
  # before(:each) do { expect( controller.class.skip_before_action ).to receive(:authenticate!).and_return(true) } end

  describe 'POST #create' do
    let(:params) { default_params.merge({invite: { email: 'invited@person.com' }}) }

    it 'should raise error' do
      create :invite, website: website, email: 'invited@person.com'
      expect{ post_with user, params }.to raise_error
      # expect{ post_with user, params }.to raise_exception(InvitesController, "Duplicate invites")
    end

    it 'should create invite' do
      expect{
        post_with user, :create, params
      }.to change(Invite, :count).by(1)
    end

    it 'should redirect' do
      expect(post_with user, :create, params).to redirect_to(new_invite_url)
      expect(response.status).to be(302)
    end

    it 'should email user' do
      mailer = double('UserMailer')
      expect(mailer).to receive(:deliver_later)
      expect(UserMailer).to receive(:member_invitation).with(an_instance_of(Fixnum)).and_return(mailer).once

      post_with user, :create, params
    end
  end

  describe 'GET #show' do

    context 'already member' do
      let!(:user2) { create :user, email: 'user@email.com'}
      let(:invite2) { create :invite, website: website, invited_by_id: user.id, email: user2.email}
      let(:params) { default_params.merge({id: invite.id,  token: invite2.token }) }

      it 'should create website_member' do
        expect{
          get_with user, :show, params
          }.to change(WebsiteMember, :count).by(1)
      end

      it 'should redirect to root' do
        expect(get_with user, :show, params).to redirect_to(root_url)
      end
    end

    context 'new member' do
      let(:params) { default_params.merge({id: invite.id,  token: invite.token }) }
      it 'it should logout user' do
        get_with user, :show, params
        expect(session[:epiclogger_website_id]).to be_nil
      end

      it 'redirect to signup' do
        expect(get_with user, :show, params).to redirect_to(signup_url(token: invite.token, email: invite.email))
      end
    end
  end
end