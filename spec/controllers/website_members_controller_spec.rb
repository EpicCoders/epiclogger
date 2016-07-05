require 'rails_helper'

RSpec.describe WebsiteMembersController, :type => :controller do
  let(:user) { create :user }
  let(:website) { create :website }
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

  describe "PUT #update" do
    let(:params) {{ id: website_member.id, website_member: { realtime: 1, daily_reporting: 1, weekly_reporting: 0, frequent_event: 1 } }}

    it "should update user" do
      expect{
        put_with user, :update, params
        website_member.reload
      }.to change{ website_member.realtime }.from(false).to(true)
       .and change{ website_member.daily_reporting }.from(false).to(true)
       .and change{ website_member.weekly_reporting }.from(true).to(false)
       .and change{ website_member.frequent_event }.from(false).to(true)
    end

    it 'should redirect to notifications tab' do
      expect( put_with user, :update, params ).to redirect_to(redirect_to installations_url(details_tab: 'notifications', main_tab: 'details'))
      expect( flash[:notice] ).to eq('Successfully updated')
    end
  end

  describe "DELETE #destroy" do
    let(:user2) { create :user, email: 'user@email.com' }
    let!(:website_member2) { create :website_member, user: user2, website: website }
    let(:params) {{ id: website_member2.id}}

    it 'should delete record' do
      expect{
        delete_with user, :destroy, params
        }.to change(WebsiteMember, :count).by(-1)
    end

    it 'should redirect' do
      expect( delete_with user, :destroy, params ).to redirect_to(website_members_url)
    end

    it 'should return false' do
      delete_with user, :destroy, params
      expect( delete_with user, :destroy, params ).to redirect_to(website_members_url)
      expect( flash[:notice] ).to eq('Website must have at least one owner')
    end
  end
end