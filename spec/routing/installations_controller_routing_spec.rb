require 'rails_helper'

RSpec.describe InstallationsController, type: :routing do
  let(:user) { create :user }
  let(:website) { create :website }
  let(:website_member) { create :website_member, website: website, user: user }

  describe 'routing' do
    it 'routes to #installations/index' do
      expect(get("/installations")).to route_to('installations#index')
    end
  end
end