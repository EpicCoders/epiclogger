require 'rails_helper'

RSpec.describe AuthController, type: :controller, as: "auths" do
  let(:user) { create :user }
  let(:website) { create :website }
  let(:group) { create :grouped_issue, website: website, last_seen: Time.now - 1.day }
  let(:default_params) { { integration: { name: "", provider: "" } } }

  describe "POST #create" do
    context "driver was not found" do
      it "redirects to integrations page with message: Invalid Integration" do
        default_params[:integration][:name] = "nodriver"
        default_params[:integration][:provider] = "nodriver"
        post_with user, :create, default_params
        expect(response).to redirect_to(settings_path(main_tab: 'integrations'))
        expect(flash[:notice]).to eq('Invalid Integration')
      end
    end

    context "driver is available" do
      before(:each) do session[:epiclogger_website_id] = website.id end
      let(:params) { { integration: { name: "Github", provider: "github" } } }

      context "integration is invalid" do
        it "redirects to integrations page if the integration could not be built" do
          params[:integration].delete(:name)
          post_with user, :create, params
          expect(response).to redirect_to(settings_path(main_tab: 'integrations'))
          expect(flash[:notice]).to eq('Integration parameters are invalid!')
        end
      end

      context "integration is valid" do
        it "assigns the current_website to the new integration" do
          post_with user, :create, params
          expect(assigns(:integration).website).to eq(website)
        end

        it "adds integration_params to the session" do
          post_with user, :create, params
          expect(session['integration']).to eq( { "name" => params[:integration][:name], "provider" => params[:integration][:provider] } )
        end

        it "redirects to the provider url" do
          post_with user, :create, params
          expect(response).to redirect_to("/auth/" + assigns(:integration).provider)
        end
      end
    end
  end

  describe "GET #success" do
    let(:omniauth_hash) { { 'provider' => 'github',
                            'uid' => '12345',
                            'info' => {
                            'name' => 'natasha',
                            'email' => 'hi@natashatherobot.com',
                            'nickname' => 'NatashaTheRobot'
                          },
                          'credentials' =>
                            {
                              'token' => '445da8f3214dafaaffb11f9f71c2ed8612287ac8',
                              'expires' => false
                            },

                          'extra' =>
                            {
                              'raw_info' => {
                                'login' => 'natasha'
                              }
                            }
                        } }
    before(:each) do
      request.env['omniauth.auth'] = omniauth_hash
    end

    context "user not logged in" do
      it "should create a new user if it does not already exist" do
        get :success, provider: 'github'
        expect(User.find_by_email(omniauth_hash['info']['email'])).to_not be_nil
      end

      it "authenticates the user" do
        get :success, provider: 'github'
        expect(request.env['warden'].user.uid).to eq(omniauth_hash['uid'])
      end
    end

    context 'user has no websites' do
      it "redirects to website_wizard_path#create if the user has no websites" do
        no_websites_user = FactoryGirl.create(:user, { provider: omniauth_hash['provider'], uid: omniauth_hash['uid'], name: omniauth_hash['info']['name'], email: omniauth_hash['info']['email'] })
        get :success, provider: 'github'
        expect(response).to redirect_to(website_wizard_path(:create))
      end
    end

    context 'user exists and has websites' do
      let!(:new_user) { create :user, provider: omniauth_hash['provider'], uid: omniauth_hash['uid'], name: omniauth_hash['info']['name'], email: omniauth_hash['info']['email'] }
      let!(:new_website_member) { create :website_member, user: new_user, website: website }

      it "sets the website to the first website of the user" do
        get :success, provider: 'github'
        expect(session['epiclogger_website_id']).to eq(new_user.websites.first.id)
      end

      it "redirects to errors_url if a website was selected" do
        get :success, provider: 'github'
        expect(response).to redirect_to(errors_path())
      end

      context "with integration_session" do
        it "creates a new integration based on the auth hash" do
          session[:integration] = { "name" => "Github", "provider" => "github" }
          get :success, provider: 'github'
          expect(assigns(:integration).website).to eq(website)
        end

        it "redirects to the installations path" do
          session[:integration] = { "name" => "Github", "provider" => "github" }
          get :success, provider: 'github'
          expect(response).to redirect_to(settings_path(main_tab: 'integrations', integration_tab: omniauth_hash['provider'] ))
        end

        it "throws error if the integration cannot be built" do
          request.env['omniauth.auth'].delete('extra')
          session[:integration] = { "name" => "Github", "provider" => "github" }
          get :success, provider: 'github'
          expect(flash[:error]).to eq("Error creating integration")
          expect(response).to redirect_to(settings_path(main_tab: 'integrations'))
        end
      end
    end
  end
end
