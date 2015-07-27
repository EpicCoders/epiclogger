require 'rails_helper'
include Devise::TestHelpers


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
      subscriber2 = create :subscriber, website: website
      subscriber_issue = create :subscriber_issue, issue: issue_error, subscriber: subscriber2
      mailer = double('UserMailer')
      expect(mailer).to receive(:deliver_now).twice
      expect(UserMailer).to receive(:issue_solved).with(issue_error, an_instance_of(Subscriber), message).and_return(mailer).twice
      post :notify_subscribers, { message: message, id: issue_error.id, format: :json }
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
      # sign_in member
      auth_request(member)
      binding.pry
      get :index, { id: member.websites.first.id, errors: website.issues, subscribers: website.subscribers.count, format: :json}
      expect(assigns(:website)).to eq(website.id)
    end

    # it 'should render json' do
    #   get :index, errors: { website: website.id, error: issue_error.id , format: :json }
    #   expect(response).to be_successful
    #   expect(response.content_type).to eq('application/json')
    # end
  end

  # describe 'GET #show' do
  #   it 'should assign error' do
  #     FactoryGirl.create( website: {website: website.id, title: "Wazzaa",domain: "wazzaa@website.com", member: member.id })
  #     get :show, { id: issue_error.id, error: {status: issue_error.status }, format: :json }
  #     expect(assigns(:error)).to eq(issue_error)
  #   end
  #   it 'should render json' do
  #     get :show, { id: issue_error.id, error: { status: issue_error.status, web: issue_error.website }, format: :json }
  #     expect(response).to be_successful
  #     expect(response.content_type).to eq('application/json')
  #   end
  # end

  # describe 'PUT #update' do
  #   it 'should assign error' do
  #     put :update, { id: issue_error.id, error: {status: issue_error.status }, format: :json }
  #     expect(assigns(:error)).to eq(issue_error)
  #   end

  #   it 'should update error status' do
  #     put :update, { id: issue_error.id, error: { error: issue_error.status }, web: website.id, format: :json }
  #     # here check if issue_error.status is updated please use changed()
  #     # expect(:update).to change(issue_error.status, :status)
  #     expect{:update}.to change{issue_error.status}.from("unresolved").to("resolved")
  #     expect(response).to be_successful
  #   end

  #   it 'should not allow update of other parameters other than status' do
  #     put :update, { id: issue_error.id, error: { error: issue_error.status }, web: website, format: :json }
  #     # here check if the other attribute not web is changed... !! strong params filters the wrong arguments so there is no error
  #     expect{:update}.not_to change{issue_error.status}.from("unresolved")
  #     expect(response).not_to have_http_status(200)
  #   end

  #   it 'should render json' do
  #     put :update, { id: issue_error.id, error: { status: issue_error.status, web: issue_error.website }, format: :json }
  #     expect(response).to be_successful
  #     expect(response.content_type).to eq('application/json')
  #   end
  # end
end