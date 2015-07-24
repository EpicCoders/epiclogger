require 'rails_helper'

describe Api::V1::ErrorsController, :type => :controller do
  let(:member) { create :member }
  let(:website) { create :website, member: member }
  let(:issue_error) { create :issue, website: website }
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_subscriber) { create :subscriber_issue, issue: issue_error, subscriber: subscriber }
  let(:message) { 'caca maca mesage' }

  describe 'POST #notify_subscribers' do
    it 'should email subscribers' do
      mailer = double('UserMailer')
      expect(mailer).to receive(:deliver_now)
      expect(UserMailer).to receive(:issue_solved).with(issue_error, subscriber, message).and_return(mailer).once

      post :notify_subscribers, { message: message, id: issue_error.id, format: :json }
    end
    # here we create another subscriber with issue_subscriber so the email is called twice
    it 'should email 2 subscribers' do
      create :subscriber, :issue_subscriber
      expect(UserMailer).to receive(:issue_solved).with(issue_error, subscriber, message).and_return(mailer).twice
    end
    # use assigns here
    it 'should assign error' do
      # call create. use assigns like i wrote it below
      expect(UserMailer).to assigns(:issue_error).to(:website)
    end
    it 'should assign message' do
      # call create. use assigns like i wrote it below
      expect(UserMailer).to assigns(:message).to(issue_error)
    end
  end

  describe 'GET #index' do
    # call the fucking get :index method wtf ....
    it 'should get current_site errors' do
      get :issue_error
      member.should_receive(:issue_error)
    end
    it 'should render json' do
      # look below
      expext(response).to respond_with 200
      expect(response).to respond_with_content_type(:json)
    end
  end

  describe 'GET #show' do
    # don't forget to use get :show here as reponse does not assign itself ... wtf
    it 'should assign error' do
      # look below how i wrote the assigns test this is shit!
      # expect(:show).to assigns(:issue_error).to(:website)
    end
    it 'should render json' do
      # look below how i wrote this test!
      expext(response).to respond_with 200
      expect(response).to respond_with_content_type(:json)
    end
  end

  describe 'PUT #update' do
    it 'should assign error' do
      put :update, { id: issue_error.id, error: {status: issue_error.status }, format: :json }
      expect(assigns(:error)).to eq(issue_error)
    end
    it 'should update error status' do
      put :update, { id: issue_error.id, error: { status: issue_error.status }, format: :json }
      # here check if issue_error.status is updated please use changed()
      expect(response).to be_successful
    end
    it 'should not allow update of other parameters other than status' do
      put :update, { id: issue_error.id, error: { status: issue_error.status, web: issue_error.website }, format: :json }
      # here check if the other attribute not web is changed... !! strong params filters the wrong arguments so there is no error
      expect(response).not_to be_successful
    end
    it 'should render json' do
      put :update, { id: issue_error.id, error: { status: issue_error.status, web: issue_error.website }, format: :json }
      expect(response).to be_successful
      expect(response.content_type).to eq('application/json')
    end
  end
end

