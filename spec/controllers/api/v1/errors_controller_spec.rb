require 'rails_helper'

describe Api::V1::ErrorsController, :type => :controller do
  let(:member) { FactoryGirl.create :member }
  let(:website) { FactoryGirl.create :website, member: member }
  let(:issue_error) { FactoryGirl.create :issue, website: website }
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
    it 'should email 2 subscribers'
    # use assigns here
    it 'should assign error'
    it 'should assign message'
  end

  describe 'GET #index' do
    it 'should get current_site errors'
    it 'should render json'
  end

  describe 'GET #show' do
    it 'should assign error'
    it 'should render json'
  end

  describe 'PUT #update' do
    it 'should assign error'
    it 'should update error status'
    it 'should not allow update of other parameters other than status'
    it 'should render json'
  end
end


