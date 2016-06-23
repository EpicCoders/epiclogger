require 'rails_helper'

RSpec.describe SubscribersController, :type => :controller do
  let(:user) { create :user }
  let(:website) { create :website }
  let!(:website_member) { create :website_member, website: website, user: user }
  let(:subscriber) { create :subscriber, website: website }
  let(:default_params) { { id: subscriber.id } }
  before(:each) do session[:epiclogger_website_id] = website.id end

  it 'should load_and_authorize_resource' do
    allow_any_instance_of(CanCan::ControllerResource).to receive(:load_and_authorize_resource)
    get_with user, :index
  end

  describe "GET #index" do
    it 'should get subscribers' do
    	get_with user, :index
    	expect(assigns(:subscribers)).to eq([subscriber])
    end
  end

  describe "DELETE #destroy" do
    it 'should delete record' do
    	subscriber2 = create :subscriber, website: website
      expect{
        delete_with user, :destroy, id: subscriber2.id
        }.to change(Subscriber, :count).by(-1)
    end

    it 'should redirect' do
      expect( delete_with user, :destroy, default_params ).to redirect_to(subscribers_url)
    end
  end
end