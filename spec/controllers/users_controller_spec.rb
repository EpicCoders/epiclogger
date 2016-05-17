require 'rails_helper'

RSpec.describe UsersController, :type => :controller do
  let(:user) { create :user }
  let(:website) { create :website }
  let!(:website_member) { create :website_member, website: website, user: user }
  let(:default_params) { { website_id: website.id, format: :json } }

  describe "GET index" do
    let(:params) { default_params.merge({}) }

    it "returns http success" do
      get_with user, :index, params
      expect(response).to be_success
    end
  end

  describe "GET new" do
    let(:params) { default_params.merge({}) }

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

  describe "POST create" do
    context "without invitation" do
      let(:params) { default_params.merge({ user: { name: 'Name for user', email: 'example@email.com', password: 'password' } }) }

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
      let!(:website_member2) { create :website_member, invitation_token: 'randomString', website_id: website.id, user_id: nil }
      let(:params) { default_params.merge({ invitation_token: website_member2.invitation_token, user: { name: 'Name for user', email: 'example@email.com', password: 'password' } }) }

      it "updates websites member" do
        expect{
          post :create, params
          website_member2.reload
        }.to change(website_member2, :user_id).from(nil)
        .and change(website_member2, :role).from("owner").to("user")
      end

      it "sets current_website" do
        post :create, params
        expect(session[:epiclogger_website_id]).to eq(website.id)
      end

      it "should email user" do
        mailer = double('UserMailer')
        expect(mailer).to receive(:deliver_later)
        expect(UserMailer).to receive(:email_confirmation).with(anything()).and_return(mailer).once

        post :create, params
      end

      it "redirects to /errors" do
        expect( post :create, params ).to redirect_to(errors_url())
      end
    end
  end

end
