require 'rails_helper'

RSpec.describe ResetPasswordController, :type => :controller do
  let(:user) { create :user }

  describe "GET new" do
    it 'should render layout' do
      get :new
      expect(response).to render_template(:layout => 'landing')
    end

    it 'returns http success' do
      get :new
      expect(response.status).to eq(200)
    end
  end

  describe "POST #create" do
    context 'blank email field' do
      it "should notice and render new" do
        post :create, { user: { email: '' } }
        expect(flash[:alert]).to eq('Specify an email address')
        expect(response).to render_template('new')
      end
    end

    context 'when user' do
      let(:params) { { user: { email: user.email } }}

      it 'should generate token' do
        expect{
          post :create, params
          user.reload
          }.to change(user, :reset_password_token).from(nil)
      end

      it 'should update reset_password_sent_at column' do
        expect{
          post :create, params
          user.reload
          }.to change(user, :reset_password_sent_at).from(nil)
      end

      it "should email user" do
        mailer = double('UserMailer')
        expect(mailer).to receive(:deliver_later)
        expect(UserMailer).to receive(:reset_password).with(user).and_return(mailer).once

        post :create, params
      end

      it 'should redirect to login' do
        expect(post :create, params).to redirect_to(login_url)
      end

      it 'should flash' do
        post :create, params
        expect(flash[:alert]).to eq('Email sent with password reset instructions')
      end
    end

    context 'user not found' do
      it "should notice and render new" do
        post :create, { user: { email: 'user@not-existent.com' } }
        expect(flash[:alert]).to eq('No such user here')
        expect(response).to render_template('new')
      end
    end
  end

  describe "GET #edit" do
    let(:user2) { create :user, reset_password_token: 'vJq2UGPUDBZYcO7RiuxkAw', reset_password_sent_at: Time.now }
    it 'assigns user' do
      get :edit, id: user2.reset_password_token
      expect(assigns(:user)).to eq(user2)
    end

    it 'should redirect and notice' do
      expect( get :edit, id: 'random-token' ).to redirect_to(login_url)
      expect(flash[:alert]).to eq('User not found')
    end
  end

  describe "PUT #update" do
    context 'when user' do
      let(:user2) { create :user, reset_password_token: 'vJq2UGPUDBZYcO7RiuxkAw', reset_password_sent_at: Time.now }
      let(:params) { { id: user2.reset_password_token, user: { password: 'password', password_confirmation: 'password' } } }

      it 'assigns user' do
        get :update, params
        expect(assigns(:user)).to eq(user2)
      end

      it 'should update password' do
        expect{
          put :update, params
          user2.reload
        }.to change(user2, :password_digest)
      end

      it 'should redirect' do
        expect( put :update, params ).to redirect_to(login_url)
      end

      it 'should notice' do
        put :update, params
        expect(flash[:alert]).to eq('Your password has been changed')
      end
    end

    context 'user not found or period expired' do
      it 'should redirect and notice' do
        put :update, id: 'random-token'
        expect(flash[:alert]).to eq("Period expired or Password don't match")
      end
    end
  end
end
