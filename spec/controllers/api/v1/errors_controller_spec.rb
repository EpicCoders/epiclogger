require 'rails_helper'

describe Api::V1::ErrorsController, :type => :controller do
  let(:member) { FactoryGirl.create :member }
  let(:website) { FactoryGirl.create :website, member: member }
  let(:issue_error) { FactoryGirl.create :issue, website: website, status: 'status' }
  let(:subscriber) { FactoryGirl.create :subscriber, email: 'newsub@email.com', website: website }
  let!(:issue_subscriber) { FactoryGirl.create :subscriber_issue, issue: issue_error, subscriber: subscriber }
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
      FactoryGirl.create :subscriber, :issue_subscriber
      expect(UserMailer).to receive(:issue_solved).with(issue_error, subscriber, message).and_return(mailer).twice
    end
    # use assigns here
    it 'should assign error' do
      expect(UserMailer).to assigns(:issue_error).to(:website)
    end
    it 'should assign message' do
      expect(UserMailer).to assigns(:message).to(issue_error)
    end
  end

  describe 'GET #index' do
    it 'should get current_site errors' do
      get :issue_error
      member.should_receive(:issue_error)
    end
    it 'should render json' do
      expext(response).to respond_with 200
      expect(response).to respond_with_content_type(:json)
    end
  end

  describe 'GET #show' do
    it 'should assign error' do
      expect(:show).to assigns(:issue_error).to(:website)
    end
    it 'should render json' do
      expext(response).to respond_with 200
      expect(response).to respond_with_content_type(:json)
    end
  end

  describe 'PUT #update' do
    it 'should assign error' do
      expect(:subscriber).to assigns(:issue_error).to(:issue_subscriber)
    end
    it 'should update error status' do
      put :update, status: issue_error.status
      response.should be_successful
    end
    it 'should not allow update of other parameters other than status' do
      put :update, status: issue_error.status, web: issue_error.website
      response.should_not be_successful
    end
    it 'should render json' do
      expect(response).to respond with 200
      expect(response).to respond_with_content_type(:json)
    end
  end
end

