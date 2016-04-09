require 'rails_helper'

describe Api::V1::MembersController, :type => :controller do
  let(:user) { create :user }
  let(:website) {create :website}
  let!(:website_member) { create :website_member, user_id: user.id, website_id: website.id, invitation_sent_at: Time.now.utc, role: 1 }
  let(:default_params) { {website_id: website.id, format: :json} }

  render_views # this is used so we can check the json response from the controller
  describe 'PUT #create' do
    let(:invitation_member) { create :website_member, user_id: nil, website_id: website.id, invitation_sent_at: Time.now.utc }
    let(:params) { default_params.merge({ website_member: {website_id: website.id, email: user.email, token: invitation_member.invitation_token} }) }
    it 'should update website_member columns' do
      expect{
        put :create, params
        invitation_member.reload
      }.to change(invitation_member, :user_id).from(nil)
    end

    it 'should render json' do
      put :create, params
      expect(response).to be_successful
      expect(response.content_type).to eq('application/json')
    end
    it 'should render some message' do
      post :create, params
      expect(response.body).to eq({success: true, message: 'Website member is now active'}.to_json)
    end
  end

  describe 'GET #show' do
    let(:params) { default_params.merge({ id: user.id }) }
    context 'is logged in' do
      before { auth_user(user) }

      it 'should get current user' do
        get :show, params
        expect(assigns(:user)).to eq(user)
      end

      it 'should get current user no matter the parameter' do
        get :show, default_params.merge({ id: user.id + 1 })
        expect(assigns(:user)).to eq(user)
      end

      it 'should render json' do
        get :show, params
        expect(response).to be_successful
        expect(response.content_type).to eq('application/json')
      end

      it 'should render the expected json' do
        get :show, params
        expect(response).to be_successful
        expect(response.body).to eq({
          id: user.id,
          email: user.email,
          confirmed_at: user.confirmed_at
          }.to_json)
      end
    end
    it 'should give error if not logged in' do
      get :show, params
      expect(response.body).to eq({errors: ['Authorized users only.']}.to_json)
      expect(response).to have_http_status(401)
    end
  end
end
