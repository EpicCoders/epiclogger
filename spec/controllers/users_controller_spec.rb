require 'rails_helper'

RSpec.describe UsersController, :type => :controller do
  let(:user) { create :user }
  let(:website) { create :website }
  let!(:website_member) { create :website_member, website: website, user: user }
  let!(:invite) { create :invite, website: website, invited_by_id: user.id }
  let(:default_params) { { website_id: website.id } }

  describe "PUT #update" do
    let(:user2) { create :user, email: 'email@email.com' }
    let(:params) {{ id: user2.id, user: { email: 'changed@email.com' } }}

    it "should update user" do
      expect{
        put_with user2, :update, params
        user2.reload
      }.to change(user2, :email).from('email@email.com').to('changed@email.com')
    end

    it 'should redirect to edit' do
      expect( put_with user2, :update, params ).to redirect_to(edit_user_path(user2))
      expect( flash[:notice] ).to eq('User updated')
    end
  end

  describe "GET new" do
    let(:params) { default_params.merge({}) }

    it 'should render layout' do
      get :new
      expect(response).to render_template(:layout => 'landing')
    end

    it "returns http success" do
      get :new, params
      expect(response).to be_success
    end

    it "creates new user instance" do
      get :new, params
      expect( subject.instance_variable_get(:@user).id ).to be_nil
    end

    it "redirects to /create" do
      expect( get_with user, :new, params ).to redirect_to(website_wizard_path(:create))
    end

    it "redirects to /errors" do
      session[:epiclogger_website_id] = website.id
      expect( get_with user, :new, params ).to redirect_to(errors_url())
    end
  end

  describe "POST #create" do
    context "without invitation" do
      let(:params) { default_params.merge({ user: { name: 'Name for user', email: 'example@email.com', password: 'password', provider: 'email' } }) }

      it "returns http success" do
        expect{
          post :create, params
          }.to change(User, :count).by(1)
      end

      it "redirects to /create" do
        expect( post :create, params ).to redirect_to(website_wizard_path(:create))
      end
    end

    context "with invitation" do
      let(:params) { default_params.merge({ token: invite.token, user: { name: 'Name for user', email: 'example@email.com', password: 'password', provider: 'email' } }) }

      it 'should update attributes' do
        post :create, params
        user = User.find_by_email('example@email.com')

        expect(user.confirmation_token).not_to be_nil
        expect(user.confirmation_sent_at).not_to be_nil
      end

      it "should email user" do
        mailer = double('UserMailer')
        expect(mailer).to receive(:deliver_later)
        expect(UserMailer).to receive(:email_confirmation).with(anything()).and_return(mailer).once

        post :create, params
      end
    end

    context 'wrong creentials' do
      let(:params) { default_params.merge({ user: { name: 'Name for user', email: 'example@email.com', password: 'pass', provider: 'email' } }) }
      it 'should render #new' do
        expect( post :create, params ).to render_template(:new)
      end
    end
  end

  describe "GET #confirm" do
    let(:params) { default_params.merge({ id: user.id, token: user.confirmation_token }) }

    it 'should logout user' do
      post_with user, :confirm, params
      expect(session[:epiclogger_website_id]).to be_nil
    end

    it "should redirect to login user" do
      expect( post_with user, :confirm, params ).to redirect_to(login_url)
      expect( flash[:alert] ).to eq('You confirmed your email once')
    end

    it "should redirect to root" do
      expect( post_with user, :confirm, id: 'x', token: 'bad/edited-token' ).to redirect_to(login_url)
      expect( flash[:alert] ).to eq('Bad url')
    end

    it "should update user" do
      user2 = create :user, confirmed_at: nil, confirmation_sent_at: Time.now, confirmation_token: 'random-token'
      expect{
        post :confirm, id: user2.id, token: user2.confirmation_token
        user2.reload
        }.to change(user2, :confirmation_token).from('random-token').to(nil)
        .and change(user2, :confirmed_at)
    end
  end

  describe "GET #unconfirm" do
    let(:params) { default_params.merge({ id: user.id }) }

    it 'should update attributes' do
      expect{
        get :unconfirm, params
        user.reload
      }.to change( user, :confirmed_at )
       .and change( user, :confirmation_token)
       .and change( user, :confirmation_sent_at )
    end

    it 'should redirect' do
      expect( get :unconfirm, params ).to redirect_to(admin_user_path(user))
    end

    it "should email user" do
        mailer = double('UserMailer')
        expect(mailer).to receive(:deliver_later)
        expect(UserMailer).to receive(:email_confirmation).with(user).and_return(mailer).once

        get :unconfirm, params
      end
  end
end
