require 'rails_helper'

RSpec.describe WebsitesController, type: :controller do
  let(:user) { create :user }
  let(:website) { create :website }
  let(:group) { create :grouped_issue, website: website }
  let(:subscriber) { create :subscriber, website: website }
  let!(:website_member) { create :website_member, website: website, user: user }
  let(:default_params) { { website_id: website.id } }

  render_views # this is used so we can check the json response from the controller
  describe 'GET #index' do
    context 'if logged in' do

      it 'assigns websites' do
        get_with user, :index
        expect(assigns(:websites)).to eq([website])
      end
    end

    it 'gives error if not logged in' do
      get :index
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
        expect(response).to redirect_to(websites_url)
        expect(response).to have_http_status(302)
      end

      it 'redirects to new_website_path' do
        delete_with user, :destroy, params
        expect(response).to redirect_to(website_wizard_url(:create))
        expect(response).to have_http_status(302)
      end
    end

    it 'gives error if not logged in' do
      delete :destroy, params: params
      expect(response).to have_http_status(302)
    end
  end

  describe "PUT #update" do
    let(:params) { default_params.merge( id: website.id, website: { platform: "Sinatra" }, format: :js ) }

    context 'it is logged in' do

      it 'updates website params' do
        expect {
          put_with user, :update, params
          website.reload
        }.to change(website, :platform).from(nil).to('Sinatra')
      end
    end
  end

  describe 'change_current' do
    it 'changes the current website' do
      website2 = create :website
      post_with user, :change_current, { id: website2.id }
      expect(assigns(:website)).to eq(website2)
    end
  end
end
