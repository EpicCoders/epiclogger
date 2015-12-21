require 'rails_helper'

describe Api::V1::WebsitesController, :type => :controller do
  let(:member) { create :member }
  let(:website) { create :website }
  let(:group) {create :grouped_issue, website: website}
  let(:subscriber) { create :subscriber, website: website }
  let!(:website_member) { create :website_member, website: website, member: member }
  let(:default_params) { {website_id: website.id, format: :json} }

  render_views # this is used so we can check the json response from the controller
  describe 'GET #index' do
    let(:params) { default_params.merge({}) }

    context 'if logged in' do
      before { auth_member(member) }

      it 'should render json' do
        get :index, params
        expect(response).to be_successful
        expect(response.content_type).to eq('application/json')
      end

      it 'should assign websites' do
        get :index, params
        expect(assigns(:websites)).to eq([website])
      end

      it 'should render the right json' do
        get :index, params
        expect(response).to be_successful
        expect(response.body).to eq({
          websites: [
            {
              id: website.id,
              title: website.title,
              domain: website.domain,
              app_secret: website.app_secret,
              app_key: website.app_key,
              errors: website.grouped_issues.count,
              subscribers: website.subscribers.count,
              members: website.members.count
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

  describe 'POST #create' do
    let(:params) { default_params.merge({website: { domain: 'www.google.com', title: 'google'} }) }

    context 'if logged in' do
      before { auth_member(member) }

      it 'should render json' do
        post :create, params
        expect(response).to be_successful
        expect(response.content_type).to eq('application/json')
      end

      it 'should create website' do
        expect {
          post :create, params
        }.to change(Website, :count).by(1)
      end

      it 'should create a website member' do
        expect {
          post :create, params
        }.to change(WebsiteMember, :count).by(1)
      end

      it 'should render the right json' do
        post :create, params
        website = Website.find_by_domain('www.google.com')
        expect(response).to be_successful
        expect(response.body).to eq({
          id: website.id,
          domain: website.domain,
          created_at: website.created_at,
          updated_at: website.updated_at,
          title: website.title
          }.to_json)
      end
    end

    it 'should give error if not logged in' do
      post :create, params
      expect(response.body).to eq({errors: ['Authorized users only.']}.to_json)
      expect(response).to have_http_status(401)
    end
  end

  describe 'GET #show' do
    let(:params) { default_params.merge({ id: website.id}) }
    context 'if logged in' do
      before { auth_member(member) }

      it 'should assign webiste' do
        get :show, params
        expect(assigns(:website)).to eq(website)
      end

      it 'should render json' do
        get :show, params
        expect(response).to be_successful
        expect(response.content_type).to eq('application/json')
      end

      it 'gives a 404 if the website is not found' do
        get :show, default_params.merge({id: website.id + 1})
        expect(assigns(:website)).to be_nil
      end

      it 'should render the expected json' do
        get :show, params
        expect(response).to be_successful
        expect(response.body).to eq({
          id: website.id,
          app_secret: website.app_secret,
          app_key: website.app_key,
          domain: website.domain,
          title: website.title,
          errors: website.grouped_issues.count,
          subscribers: website.subscribers.count,
          members: website.members.count
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
    let(:params) { default_params.merge({ id: website.id, format: :js}) }

    context 'it is logged in' do
      before { auth_member(member) }

      it 'should delete website' do
        expect{
          delete :destroy, params
        }.to change(Website,:count).by(-1)
      end
      it 'should delete only website from current member' do
        member2 = create :member
        website2 = create :website
        website_member2 = create :website_member, member: member2, website: website2
        expect {
          delete :destroy, default_params.merge({ id: website2.id, format: :js })
        }.to change(Website, :count).by(0)
      end
      it 'should render js template' do
        delete :destroy, params
        expect(response.body).to eq("$('tr#website_#{website.id}').remove();\n")
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