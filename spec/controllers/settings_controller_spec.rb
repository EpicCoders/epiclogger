require 'rails_helper'

RSpec.describe SettingsController, type: :controller do
  let(:user) { create :user, email: 'epic@email.com' }
  let(:website) { create :website }
  let!(:website_member) { create :website_member, user_id: user.id, website_id: website.id }
  before(:each) do session[:epiclogger_website_id] = website.id end

  describe '#index' do
    it 'should assign website' do
      get_with user, :index
      expect(assigns(:website)).to eq(website)
    end

    it 'should assign default tabs' do
      get_with user, :index
      expect(assigns(:main_tab)).to eq('details')
      expect(assigns(:details_tab)).to eq('settings')
      expect(assigns(:configuration_tab)).to eq('all_platforms')
      expect(assigns(:platform_tab)).to eq('all_platforms')
    end

    it 'should assign from params' do
      get_with user, :index, main_tab: 'configuration', details_tab: 'api_keys', configuration_tab: 'ruby', platform_tab: 'rails_3'
      expect(assigns(:main_tab)).to eq('configuration')
      expect(assigns(:details_tab)).to eq('api_keys')
      expect(assigns(:configuration_tab)).to eq('ruby')
      expect(assigns(:platform_tab)).to eq('rails_3')
    end

    it 'should assign options' do
      get_with user, :index
      expect(assigns(:options)).to eq(["Javascript", "Python", "Django", "Flask", "Tornado", "Php", "Ruby", "Rails 3", "Rails 4", "Sinatra", "Sidekiq", "Node js", "Express", "Connect", "Java", "Google app engine", "Log4j", "Log4j 2", "Logback", "Objective-C"])
    end
  end
end
