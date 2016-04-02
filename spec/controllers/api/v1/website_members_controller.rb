require 'rails_helper'

describe Api::V1::WebsiteMembersController, :type => :controller do
  let(:user) { create :user }
  let(:website) {create :website}
  let!(:website_member) { create :website_member, user_id: user.id, website_id: website.id, invitation_sent_at: Time.now.utc, role: 1 }
  let(:default_params) { {website_id: website.id, format: :json} }

  render_views # this is used so we can check the json response from the controller
  describe 'GET #index' do
    let(:params) { default_params.merge({ website_id: website.id, user_id: user.id}) }
    context 'is logged in' do
      before { auth_user(user) }

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
                id: website_member.id,
                role: website_member.role,
                name: user.name,
                email: user.email
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

  describe 'DELETE #destroy' do
    let!(:user2) {create :user}
    let!(:website_member2) { create :website_member, user_id: user2.id, website_id: website.id, role: 2 }
    let(:params) { default_params.merge({ id: website_member2.id, format: :js }) }
    context 'is logged in' do
      before { auth_user(user) }

      it 'should delete website user' do
        expect{
          delete :destroy, params
        }.to change(WebsiteMember, :count).by(-1)
      end

      it 'should render js template' do
        delete :destroy, params
        expect(response.body).to eq("$('tr#member_#{website_member2.id}').remove();\n")
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
