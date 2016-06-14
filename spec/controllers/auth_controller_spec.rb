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
        expect(response).to redirect_to(installations_path(main_tab: 'integrations'))
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
          expect(response).to redirect_to(installations_path(main_tab: 'integrations'))
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
                            'extra' =>  { 'raw_info' =>
                                          { 'location' => 'San Francisco',
                                            'gravatar_id' => '123456789'
                                          }
                                        }
                        } }
    before(:each) do
      session[:epiclogger_website_id] = website.id
      request.env['omniauth.auth'] = omniauth_hash
      get "success", provider: 'github'
    end

    xit "creates a new integration based on the auth hash"
  end
end
