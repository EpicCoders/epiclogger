require 'rails_helper'

RSpec.describe Api::V1::ErrorsController, :type => :controller do

  describe "NotifySubscribers"  do
    let(:issue) { FactoryGirl.create(:issue) } 
    let(:subscriber) { FactoryGirl.create :subscriber, issue_id: issue.id }

    it "should email subscribers" do
      subscriber = FactoryGirl.create(:member)
      post :notify_subscribers, {message: 'asdadasdad', id: issue.id}
      expect(UserMailer).to receive(:issue_solved).once
      subscriber.notify_subscribers
    end
  end


  describe "PUT #update" do
    it "shoult update error stauts" do
      error = FactoryGirl.create :issue
    end
  end

end


