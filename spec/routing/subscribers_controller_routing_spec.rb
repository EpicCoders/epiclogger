require 'rails_helper'

RSpec.describe SubscribersController, type: :routing do
  let(:user) { create :user }
  let(:website) { create :website }
  let(:website_member) { create :website_member, website: website, user: user }
  let(:subscriber) { create :subscriber, website: website }

  describe 'routing' do
    it 'routes to #subscribers/index' do
      expect(get("/subscribers")).to route_to('subscribers#index')
    end
  end
end