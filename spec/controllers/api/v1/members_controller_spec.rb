require 'rails_helper'

describe Api::V1::MembersController, :type => :controller do
  let(:member) { create :member }
  let(:website) {create :website}
  let!(:website_member) { create :website_member, member_id: member.id, website_id: website.id, invitation_sent_at: Time.now.utc }
  let(:default_params) { {website_id: website.id, format: :json} }

  render_views # this is used so we can check the json response from the controller
  describe 'GET #index' do
    let(:params) { default_params.merge({ website_id: website.id, member_id: member.id}) }
    context 'is logged in' do
      before { auth_member(member) }

      it 'should render json' do
        get :index, params
        expect(response).to be_successful
        expect(response.content_type).to eq('application/json')
      end

      it 'should render the expected json' do
        get :index, params
        expect(response).to be_successful
        expect(response.body).to eq({
            members: [
              {
                id: member.id,
                name: member.name,
                email: member.email,
                role: website_member.role
              }
            ]
          }.to_json)
      end
    end
    it 'should give error if not logged in' do
      get :index, params
      expect(response.body).to eq({errors: ['Authorized users only.']}.to_json)
      expect(response).to have_http_status(401)
    end
  end
  describe 'PUT #create' do
    let(:invitation_member) { create :website_member, member_id: nil, website_id: website.id, invitation_sent_at: Time.now.utc }
    let(:params) { default_params.merge({ website_member: {website_id: website.id, email: member.email, token: invitation_member.invitation_token} }) }
    it 'should update website_member columns' do
      expect{
        put :create, params
        invitation_member.reload
      }.to change(invitation_member, :member_id).from(nil)
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
    let(:params) { default_params.merge({ id: member.id }) }
    context 'is logged in' do
      before { auth_member(member) }

      it 'should get current member' do
        get :show, params
        expect(assigns(:member)).to eq(member)
      end

      it 'should get current member no matter the parameter' do
        get :show, default_params.merge({ id: member.id + 1 })
        expect(assigns(:member)).to eq(member)
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
          id: member.id,
          email: member.email,
          confirmed_at: member.confirmed_at
          }.to_json)
      end
    end
    it 'should give error if not logged in' do
      get :show, params
      expect(response.body).to eq({errors: ['Authorized users only.']}.to_json)
      expect(response).to have_http_status(401)
    end
  end

  describe 'DELETE #destroy' do
    let(:params) { default_params.merge({ id: member.id, format: :js }) }
    context 'is logged in' do
      before { auth_member(member) }

      it 'should delete member' do
        expect{
          delete :destroy, params
        }.to change(Member, :count).by(-1)
      end

      it 'should render js template' do
        delete :destroy, params
        expect(response.body).to eq("$('tr#member_#{member.id}').remove();\n")
        expect(response.content_type).to eq('text/javascript')
        expect(response).to have_http_status(200)
      end
    end
    it 'should give error if not logged in' do
      delete :destroy, params
      expect(response.body).to eq({errors: ['Authorized users only.']}.to_json)
      expect(response).to have_http_status(401)
    end
  end
end