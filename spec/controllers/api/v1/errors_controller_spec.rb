require 'rails_helper'

describe Api::V1::ErrorsController, :type => :controller do
  let(:member) { create :member }
  let(:website) { create :website, member: member }
  let(:issue_error) { create :issue, website: website }
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_subscriber) { create :subscriber_issue, issue: issue_error, subscriber: subscriber }
  let(:message) { 'asdada' }

  describe 'POST #notify_subscribers' do
    it 'should email subscribers' do
      mailer = double('UserMailer')
      expect(mailer).to receive(:deliver_now)
      expect(UserMailer).to receive(:issue_solved).with(issue_error, subscriber, message).and_return(mailer).once

      post :notify_subscribers, { message: message, id: issue_error.id, format: :json }
    end

    #here we create another subscriber with issue_subscriber so the email is called twice
    it 'should email 2 subscribers' do
      subscriber = FactoryGirl.create :subscriber, {issue_subscriber: issue_error.id , website: website}
      expect(UserMailer).to receive(:issue_solved).with(issue_error, subscriber, message).and_return(mailer).twice
    end

    it 'should assign error' do
      post :notify_subscribers, { id: issue_error.id, error: {status: issue_error.status }, format: :json }
      expect(assigns(:error)).to eq(issue_error)
      # call create. use assigns like i wrote it below
    end

    it 'should assign message' do
      # call create. use assigns like i wrote it below
      post :notify_subscribers, { message: 'asdada', id: issue_error.id, format: :json }
      expect(assigns(:message)).to eq('asdada')
    end
  end

  describe 'GET #index' do
    it 'should get current_site errors' do
      #Factory not registered: {:website=>{:website=>981, :title=>"Wazzaa", :domain=>"wazzaa@website.com", :member=>989}}
      FactoryGirl.create( website: {website: website.id, title: "Wazzaa",domain: "wazzaa@website.com", member: member.id })
      get :index, { website: website, member: member.id, format: :json}
      expect(assigns(:website)).to eq(website.id)
    end

    it 'should render json' do
      #undefined method `issues' for nil:NilClass
      get :index, errors: { website: website.id, error: issue_error.id , format: :json }
      expect(response).to be_successful
      expect(response.content_type).to eq('application/json')
    end
  end

  describe 'GET #show' do
    it 'should assign error' do
      #Factory not registered: {:website=>{:website=>983, :title=>"Wazzaa", :domain=>"wazzaa@website.com", :member=>991}}
      FactoryGirl.create( website: {website: website.id, title: "Wazzaa",domain: "wazzaa@website.com", member: member.id })
      get :show, { id: issue_error.id, error: {status: issue_error.status }, format: :json }
      expect(assigns(:error)).to eq(issue_error)
    end
    it 'should render json' do
      get :show, { id: issue_error.id, error: { status: issue_error.status, web: issue_error.website }, format: :json }
      expect(response).to be_successful
      expect(response.content_type).to eq('application/json')
    end
  end

  describe 'PUT #update' do
    it 'should assign error' do
      #undefined method `issues' for nil:NilClass
      put :update, { id: issue_error.id, error: {status: issue_error.status }, format: :json }
      expect(assigns(:error)).to eq(issue_error)
    end

    it 'should update error status' do
      put :update, { id: issue_error.id, error: { error: issue_error.status }, web: website.id, format: :json }
      #expected result to have changed from "unresolved" to "resolved", but did not change
      expect{:update}.to change{issue_error.status}.from("unresolved").to("resolved")
      expect(response).to be_successful
    end

    it 'should not allow update of other parameters other than status' do
      put :update, { id: issue_error.id, error: { error: issue_error.status }, web: website, format: :json }
      expect{:update}.not_to change{issue_error.status}.from("unresolved")
      #expected the response not to have status code 200 but it did
      expect(response).not_to have_http_status(200)
    end

    it 'should render json' do
      put :update, { id: issue_error.id, error: { status: issue_error.status, web: issue_error.website }, format: :json }
      expect(response).to be_successful
      expect(response.content_type).to eq('application/json')
    end
  end
end