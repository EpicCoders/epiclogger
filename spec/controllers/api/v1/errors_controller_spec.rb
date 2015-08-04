require 'rails_helper'
include Devise::TestHelpers


describe Api::V1::ErrorsController, :type => :controller do
  let(:member) { create :member }
  let(:website) { create :website, member: member }
  let(:issue_error) { create :issue, website: website }
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_subscriber) { create :subscriber_issue, issue: issue_error, subscriber: subscriber }
  let(:message) { 'asdada' }

  describe 'POST #create' do

    it 'should create subscriber' do
      auth_member(member)
      expect {
        post :create, {subscriber: {name: 'Name for subscriber', email: 'email@example2.com'}}
      }.to change(Subscriber, :count).by( 1 )
    end

    it 'should create issue' do
      auth_member(member)
      expect {
        post :create, {issue: {description: 'Description for current error', page_title: 'Title for new page'}}
        }.to change(Issue, :count).by( 1 )
      expect(response).to be_successful
    end

    it 'should create subscriber_issue' do
      auth_member(member)
      expect {
        post :create, {subscriber_issue:{ issue_id: issue_error.id, subscriber_id: subscriber.id}}
      }.to change(SubscriberIssue, :count).by( 1 )
    end

    it 'should not create issue if issue exists' do
      auth_member(member)
      subscriber1 = create :subscriber, name: 'Name for subscriber', email: 'email@example1.com'
      error1 = create :issue, status: 'unresolved', description: 'Description for current error', page_title: 'Title for new page'
      subscriber_issue1 = create :subscriber_issue, issue_id: issue_error.id, subscriber_id: subscriber.id
      expect{
        post :create, { id: error1.id, website_id: website.id, email: subscriber1.email, name: subscriber1.name, format: :json }
      }.to change(Issue, :count).by(0)
    end

    it 'should create message' do
      expect {
        post :create, message: {content: 'content for message', issue_id: issue_error.id}
      }.to change(Message, :count).by( 1 )
    end

  end

  describe 'POST #notify_subscribers' do
    before { auth_member(member) }

    it 'should email subscribers' do
      mailer = double('UserMailer')
      expect(mailer).to receive(:deliver_now)
      expect(UserMailer).to receive(:notify_subscriber).with(issue_error, subscriber, message).and_return(mailer).once

      post :notify_subscribers, { message: message, id: issue_error.id, format: :json }
    end

    it 'should email 2 subscribers' do
      subscriber2 = create :subscriber, website: website
      subscriber_issue = create :subscriber_issue, issue: issue_error, subscriber: subscriber2
      mailer = double('UserMailer')
      expect(mailer).to receive(:deliver_now).twice
      expect(UserMailer).to receive(:notify_subscriber).with(issue_error, an_instance_of(Subscriber), message).and_return(mailer).twice
      post :notify_subscribers, { message: message, id: issue_error.id, format: :json }
    end

    it 'should assign error' do
      post :notify_subscribers, { id: issue_error.id, error: {status: issue_error.status }, format: :json }
      expect(assigns(:error)).to eq(issue_error)
    end

    it 'should assign message' do
      post :notify_subscribers, { message: 'asdada', id: issue_error.id, format: :json }
      expect(assigns(:message)).to eq('asdada')
    end
  end

  describe 'GET #index' do
    it 'should assign current_site errors' do
      auth_member(member)
      get :index, { website_id: website.id, format: :json}
      expect(assigns(:errors)).to eq([issue_error])
    end

    it 'should give error if not logged in' do
      get :index, { website_id: website.id, format: :json}
      expect(response.body).to eq({errors: ['Authorized users only.']}.to_json)
      expect(response).to have_http_status(401)
    end

    it 'should render json' do
      auth_member(member)
      get :index, { website_id: website.id, format: :json}
      expect(response).to be_successful
      expect(response.content_type).to eq('application/json')
    end
  end

  describe 'GET #show' do
    it 'should assign error' do
      auth_member(member)
      get :show, { id: issue_error.id, website_id: website.id, format: :json }
      expect(assigns(:error)).to eq(issue_error)
    end

    it 'should give error if not logged in' do
      get :show, { id: issue_error.id, website_id: website.id, format: :json }
      expect(response.body).to eq({errors: ['Authorized users only.']}.to_json)
      expect(response).to have_http_status(401)
    end

    it 'should render json' do
      auth_member(member)
      get :show, { id: issue_error.id, website_id: website.id, format: :json }
      expect(response).to be_successful
      expect(response.content_type).to eq('application/json')
    end
  end

  describe 'PUT #update' do
    it 'should assign error' do
      auth_member(member)
      put :update, { id: issue_error.id, error: {status: issue_error.status }, format: :json }
      expect(assigns(:error)).to eq(issue_error)
    end

    it 'should update error status' do
      auth_member(member)
      expect {
        put :update, { id: issue_error.id,  error: { status: "resolved" }, website_id: website.id, format: :json}
        issue_error.reload
      }.to change(issue_error, :status).from('unresolved').to('resolved')
    end

    it 'should not allow update of other parameters other than status' do
      auth_member(member)
      expect{
        put :update, { id: issue_error.id, error: { error: issue_error.status }, website: website.id, format: :json }
      }.to_not change(issue_error, :status).from("unresolved")
    end

    it 'should render json' do
      auth_member(member)
      put :update, { id: issue_error.id, error: { status: 'resolved' }, format: :json }
      expect(response).to be_successful
      expect(response.content_type).to eq('application/json')
    end
  end
end