require 'rails_helper'

RSpec.describe SessionsController, :type => :controller do
  let(:user) { create :user }
  let(:website) { create :website }
  let!(:website_member) { create :website_member, website: website, user: user }

  describe "GET new" do
    it 'should render layout' do
      get :new
      expect(response).to render_template(:layout => 'landing')
    end

    it 'returns http success' do
      get :new
      expect(response.status).to eq(200)
    end

    it 'returns User.new' do
      get :new
      expect(assigns(:user)).to be_an_instance_of(User)
    end

    it 'should redirect to create' do
      user2 = create :user
      expect( get_with user2, :new ).to redirect_to(website_wizard_path(:create))
    end
  end

  describe "POST #create" do
    let(:params) {{ user: { email: user.email, password: user.password } }}

    it 'should auth user' do
      allow(request.env['warden']).to receive(:authenticate!).and_return(user)
      allow(controller).to receive(:current_user).and_return(user)

      post :create, params
    end

    it 'should set current_website' do
      post :create, params
      expect(session[:epiclogger_website_id]).to eq(website.id)
    end

    it 'should redirect to create' do
      user2 = create :user, email: "user@email.com"
      expect( post :create, user: { email: user2.email, password: user2.password } ).to redirect_to(website_wizard_path(:create))
    end

    it 'should redirect to errors' do
      expect( post :create, user: { email: user.email, password: user.password } ).to redirect_to(errors_path)
    end
  end
end
