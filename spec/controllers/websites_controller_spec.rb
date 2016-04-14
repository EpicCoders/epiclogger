require 'rails_helper'

RSpec.describe WebsitesController, type: :controller do
  let(:user) { create :user }
  let(:website) { create :website }
  let(:group) { create :grouped_issue, website: website }
  let(:subscriber) { create :subscriber, website: website }
  let!(:website_member) { create :website_member, website: website, user: user }
  let(:default_params) { { website_id: website.id, format: :json } }

  render_views # this is used so we can check the json response from the controller
  describe 'GET #index' do
    let(:params) { default_params.merge({}) }

    context 'if logged in' do

      it 'renders json' do
        get_with user, :index, params
        expect(response).to be_successful
        expect(response.content_type).to eq('application/json')
      end

      it 'assigns websites' do
        get_with user, :index, params
        expect(assigns(:websites)).to eq([website])
      end

      it 'renders the right json' do
        get_with user, :index, params
        expect(response).to be_successful
        expect(response.body).to eq({
          websites: [
            {
              id: website.id,
              title: website.title,
              domain: website.domain,
              app_secret: website.app_secret,
              app_key: website.app_key
            }
          ]
        }.to_json)
      end
    end

    it 'gives error if not logged in' do
      get :index, params
      expect(response).to have_http_status(302)
    end
  end

  describe 'DELETE #destroy' do
    let(:params) { default_params.merge(id: website.id, format: :js) }

    context 'it is logged in' do

      it 'deletes website' do
        expect{
          delete_with user, :destroy, params
        }.to change(Website, :count).by(-1)
      end

      it 'deletes only website from current user' do
        user2 = create :user, provider: "mail"
        website2 = create :website, title: 'Title for website', domain: 'http://www.new-website.com'
        create :website_member, user: user2, website: website2
        expect{
          delete_with user, :destroy, default_params.merge(id: website2.id, format: :js)
        }.to change(Website, :count).by(0)
        expect(response).to have_http_status(302)
      end

      it 'reloads page' do
        website2 = create :website, title: 'Website title', domain: 'http://www.second-website.com'
        create :website_member, user: user, website: website2
        delete_with user, :destroy, params
        expect(response.body).to eq('location.reload();')
        expect(response.content_type).to eq('text/javascript')
        expect(response).to have_http_status(200)
      end

      it 'redirects to new_website_path' do
        delete_with user, :destroy, params
        expect(response.body).to eq("location.href='/website_wizard/create';")
        expect(response.content_type).to eq('text/javascript')
        expect(response).to have_http_status(200)
      end
    end

    it 'gives error if not logged in' do
      delete :destroy, params
      expect(response).to have_http_status(302)
    end
  end
end
