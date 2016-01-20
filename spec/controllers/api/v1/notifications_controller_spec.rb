require 'rails_helper'

describe Api::V1::ErrorsController, type: :controller do
  let(:member) { create :member }
  let(:website) { create :website }
  let!(:website_member) { create :website_member, website: website, member: member }
  let(:notification) { create :notification, website: website, new_event: true }
  let(:default_params) { { website_id: website.id, format: :json } }

  describe 'GET #index' do
    context 'if logged in' do
      before { auth_member(member) }
      it 'should render json' do
        get :index, default_params
        expect(response).to be_successful
        expect(response.content_type).to eq('application/json')
      end
    end
    context 'if not logged in' do
      it 'should give error' do
        get :index, default_params
        expect(response.body).to eq({ errors: ['Authorized users only.'] }.to_json)
        expect(response).to have_http_status(401)
      end
    end
  end
  describe 'PUT #update' do
    let(:params) { default_params.merge({ notification: { daily: true, realtime: false, new_event: true, frequent_event: false }, id: notification.id }) }
    context 'if logged in' do
      before { auth_member(member) }
      it 'should render json' do
        put :update, params
        expect(response).to be_successful
        expect(response.content_type).to eq('application/json')
      end
    end
    context 'if not logged in' do
      it 'should give error' do
        put :update, params
        expect(response.body).to eq({ errors: ['Authorized users only.'] }.to_json)
        expect(response).to have_http_status(401)
      end
    end
  end
end
