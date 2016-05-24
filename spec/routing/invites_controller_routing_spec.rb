require 'rails_helper'

RSpec.describe InvitesController, type: :routing do
  let(:user) { create :user }
  let(:website) { create :website }
  let(:invite) { create :invite }
  let(:website_member) { create :website_member, website: website, user: user }

  describe 'routing' do
    it 'routes to #invites/new' do
      expect(get("/invites/new")).to route_to('invites#new')
    end

    it 'routes to #invites/accept' do
      expect(get("/invites/#{invite.token}/accept")).to route_to('invites#accept', id: "#{invite.token}")
    end
  end
end