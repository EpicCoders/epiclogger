require 'rails_helper'

describe Api::V1::ErrorsController, :type => :controller do
  let(:member) { create :member }
  let(:website) { create :website }
  let!(:website_member) { create :website_member, website: website, member: member }
  let(:issue_error) { create :issue, website: website }
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_subscriber) { create :subscriber_issue, issue: issue_error, subscriber: subscriber }
  let(:message) { 'asdada' }
  let(:default_params) { {website_id: website.id, format: :json} }

  describe 'POST #create' do
    let(:params) { default_params.merge({error: { user: { email: 'email@example2.com' }, name: 'Name for subscriber', page_title: 'New title', message: 'new message'}}) }

    context 'if logged in' do
      before { auth_member(member) }
      it 'should create subscriber' do
        expect {
          post :add_error, params
        }.to change(Subscriber, :count).by( 1 )
      end

      it 'should create issue' do
        expect {
          post :add_error, params
        }.to change(Issue, :count).by( 1 )
      end

      it 'should create subscriber_issue' do
        expect {
          post :add_error, params
        }.to change(SubscriberIssue, :count).by( 1 )
      end

      it 'should create message' do
        expect {
          post :add_error, params
        }.to change(Message, :count).by( 1 )
      end

      it 'should not create issue if issue exists' do
        subscriber1 = create :subscriber, website: website, name: 'Name for subscriber', email: 'email@example2.com'
        error1 = create :issue, website: website, page_title: 'New title'
        create :subscriber_issue, issue: error1, subscriber: subscriber1
        expect{
          post :add_error, params
        }.to change(Issue, :count).by(0)
      end
    end
    context 'not logged in' do
      before { auth_member(member) }
      it 'should get current site' do
        request.env['HTTP_APP_ID'] = website.app_id
        request.env['HTTP_APP_KEY'] = website.app_key
        post :add_error, params
        expect(assigns(:current_site)).to eq(website)
      end
    end
  end

  describe 'POST #notify_subscribers' do
    before { auth_member(member) }
    let(:params) { default_params.merge({ message: message, id: issue_error.id }) }

    it 'should email subscribers' do
      mailer = double('UserMailer')
      expect(mailer).to receive(:deliver_now)
      expect(UserMailer).to receive(:notify_subscriber).with(issue_error, subscriber, message).and_return(mailer).once

      post :notify_subscribers, params
    end

    it 'should email 2 subscribers' do
      subscriber2 = create :subscriber, website: website
      subscriber_issue = create :subscriber_issue, issue: issue_error, subscriber: subscriber2
      mailer = double('UserMailer')
      expect(mailer).to receive(:deliver_now).twice
      expect(UserMailer).to receive(:notify_subscriber).with(issue_error, an_instance_of(Subscriber), message).and_return(mailer).twice
      post :notify_subscribers, params
    end

    it 'should assign message' do
      post :notify_subscribers, params
      expect(assigns(:message)).to eq('asdada')
    end
  end

  describe 'GET #index' do
    let(:params) { default_params.merge({ website_id: website.id}) }

    context 'if logged in' do
      before { auth_member(member) }

      it 'should render json' do
        get :index, params
        expect(response).to be_successful
        expect(response.content_type).to eq('application/json')
      end

      it 'should assign current_site errors' do
        auth_member(member)
        get :index, params
        expect(assigns(:errors)).to eq([issue_error])
      end
    end

    it 'should give error if not logged in' do
      get :index, params
      expect(response.body).to eq({errors: ['Authorized users only.']}.to_json)
      expect(response).to have_http_status(401)
    end
  end

  describe 'GET #show' do
    let(:params) { default_params.merge({ id: issue_error.id, website_id: website.id}) }
    render_views
    context 'if logged in' do
      before { auth_member(member) }

      it 'should assign error' do
        get :show, params
        expect(assigns(:error)).to eq(issue_error)
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
          id: issue_error.id,
          description: issue_error.description,
          created_at: issue_error.created_at,
          website_id: issue_error.website_id,
          page_title: issue_error.page_title,
          last_occurrence: issue_error.updated_at,
          subscribers: issue_error.subscribers,
          subscribers_count: issue_error.subscribers.count
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