require 'rails_helper'
include Devise::TestHelpers


describe Api::V1::ErrorsController, :type => :controller do
  let(:member) { create :member }
  let(:website) { create :website, member: member }
  let(:issue_error) { create :issue, website: website }
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_subscriber) { create :subscriber_issue, issue: issue_error, subscriber: subscriber }
  let(:message) { 'asdada' }
  let(:default_params) { {format: :json} }

  describe 'POST #create' do
    before { auth_member(member) }
    let(:params) { default_params.merge({error: {name: 'Name for subscriber', email: 'email@example2.com', page_title: 'New title', message: 'new message'}}) }

    it 'should create subscriber' do
      expect {
        post :create, params
      }.to change(Subscriber, :count).by( 1 )
    end

    it 'should create issue' do
      expect {
        post :create, params
      }.to change(Issue, :count).by( 1 )
    end

    it 'should create subscriber_issue' do
      expect {
        post :create, params
      }.to change(SubscriberIssue, :count).by( 1 )
    end

    it 'should create message' do
      expect {
        post :create, params
      }.to change(Message, :count).by( 1 )
    end

    it 'should not create issue if issue exists' do
      subscriber1 = create :subscriber, website: website, name: 'Name for subscriber', email: 'email@example2.com'
      error1 = create :issue, website: website, status: 'unresolved', page_title: 'New title'
      create :subscriber_issue, issue: error1, subscriber: subscriber1
      expect{
        post :create, params
      }.to change(Issue, :count).by(0)
    end

    it 'should increment occurrences' do
    # create a new error (error1)
    # then do expect { ...(request) + error1.reload }.to change(error1, :occurrences).by(1)
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

    it 'should assign error' do
      post :notify_subscribers, default_params.merge({ id: issue_error.id, error: {status: issue_error.status }})
      expect(assigns(:error)).to eq(issue_error)
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
    end

    it 'should give error if not logged in' do
      get :show, params
      expect(response.body).to eq({errors: ['Authorized users only.']}.to_json)
      expect(response).to have_http_status(401)
    end
  end

  describe 'PUT #update' do
    before { auth_member(member) }
    it 'should assign error' do
      put :update, { id: issue_error.id, error: {status: issue_error.status }, format: :json }
      expect(assigns(:error)).to eq(issue_error)
    end

    it 'should update error status' do
      expect {
        put :update, { id: issue_error.id,  error: { status: "resolved" }, website_id: website.id, format: :json}
        issue_error.reload
      }.to change(issue_error, :status).from('unresolved').to('resolved')
    end

    it 'should not allow update of other parameters other than status' do
      expect{
        put :update, { id: issue_error.id, error: { error: 'some' }, website: website.id, format: :json }
      }.to_not change(issue_error, :status).from("unresolved")
    end

    it 'should render json' do
      put :update, { id: issue_error.id, error: { status: 'resolved' }, format: :json }
      expect(response).to be_successful
      expect(response.content_type).to eq('application/json')
    end
  end
end