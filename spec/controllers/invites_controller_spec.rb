require 'rails_helper'

RSpec.describe InvitesController, type: :controller do
  let(:user) { create :user }
  let(:website) { create :website }
  let!(:website_member) { create :website_member, user_id: user.id, website_id: website.id }
  let(:invite) { create :invite, website: website, invited_by_id: user.id }
  let(:default_params) { {} }

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

  describe 'GET #accept' do
    let(:params) { default_params.merge({id: invite.token }) }
    let(:user2) { create :user, email: invite.email }

    context 'logged in' do

      it 'should redirect to errors' do
         expect(get_with user, :accept, params).to redirect_to(errors_url)
      end

      it 'should set current website' do
        get_with user2, :accept, params
        expect(session[:epiclogger_website_id]).to eq(website.id)
      end

      it 'should update attribute' do
        expect{
          get_with user2, :accept, params
          invite.reload
        }.to change(invite, :accepted_at).from(nil)
      end

      it 'should create website_member' do
        expect{
          get_with user2, :accept, params
          }.to change(WebsiteMember, :count).by(1)
      end
    end

    context 'logged out' do

      it 'should redirect to errors' do
         expect(get :accept, params).to redirect_to(signup_url(token: invite.token))
      end
    end
  end
end