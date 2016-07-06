require 'rails_helper'

RSpec.describe SettingsController, type: :routing do
  let(:user) { create :user }
  let(:website) { create :website }
  let(:website_member) { create :website_member, website: website, user: user }

  describe 'routing' do
    it 'routes to #settings/index' do
      expect(get("/settings")).to route_to('settings#index')
    end
  end
end