require 'rails_helper'

RSpec.describe WebsiteMembersController, :type => :controller do
  let!(:user) { create :user }
  let!(:website) { create :website }
  let!(:website_member) { create :website_member, website: website, user: user }
  before(:each) do session[:epiclogger_website_id] = website.id end

  describe "GET #index" do
    it 'should load_and_authorize_resource' do
      allow_any_instance_of(CanCan::ControllerResource).to receive(:load_and_authorize_resource)
      get_with user, :index
    end

    it 'should get website_members' do
      get_with user, :index
      expect(assigns(:website_members)).to eq(user.website_members)
    end
  end

  describe "DELETE #destroy" do
    let(:user2) { create :user, email: 'user@email.com' }
    let!(:website_member2) { create :website_member, user: user2, website: website }
    let(:params) {{ id: website_member2.id }}

    it 'should delete record' do
      expect{
        delete_with user, :destroy, params
        }.to change(WebsiteMember, :count).by(-1)
    end

    it 'should redirect' do
      expect( delete_with user, :destroy, params ).to redirect_to(website_members_path)
      expect( flash[:notice] ).to eq('Member removed')
    end
  end
end