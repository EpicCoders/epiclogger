require 'rails_helper'

describe Api::V1::MembersController, :type => :controller do
  let(:member) { create :member }
  let(:website) {create :website}
  let!(:website_member) { create :website_member, member_id: member.id, website_id: website.id, invitation_sent_at: Time.now.utc }
  let(:default_params) { {website_id: website.id, format: :json} }

  render_views # this is used so we can check the json response from the controller
  describe 'GET #index' do
    let(:params) { default_params.merge({ website_id: website.id, member_id: member.id}) }
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
  describe 'PUT #create' do
    let(:params) { default_params.merge({ website_member: {website_id: website.id, email: member.email, token: website_member.invitation_token} }) }
    # it 'should update website_member columns' do
    #   expect{
    #     put :create, params
    #     website_member.reload
    #   }.to change(website_member.member_id).from(nil)
    # end

    it 'should render json' do
      put :create, params
      expect(response).to be_successful
      expect(response.content_type).to eq('application/json')
    end
  end

  describe 'GET #show' do
    let(:params) { default_params.merge({ id: member.id }) }
    before { auth_member(member) }

    it 'should get current member' do
      get :show, params
      expect(assigns(:current_member)).to eq(member)
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

  # describe 'DELETE #destroy' do
  #   before { auth_member(member) }
  #   let(:params) { default_params.merge({ id: member.id }) }

  #   it 'should delete website' do
  #     expect{
  #       delete :destroy, params
  #       }.to change(Website,:count).by(-1)
  #   end
  # end
end