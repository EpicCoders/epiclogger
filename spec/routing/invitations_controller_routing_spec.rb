require 'rails_helper'

RSpec.describe InvitationsController, type: :routing do
  let(:user) { create :user }
  let(:website) { create :website }
  let(:website_member) { create :website_member, website: website, user: user }

  describe 'routing' do
    it 'routes to #invitations/new' do
      expect(get("/invitations/new")).to route_to('invitations#new')
    end

    it 'routes to #invitations/show' do
      expect(get("/invitations/#{user.id}")).to route_to('invitations#show', id: "#{user.id}")
    end
  end
end