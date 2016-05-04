require 'rails_helper'

RSpec.describe WebsiteMembersController, type: :routing do
  let(:user) { create :user }
  let(:website) { create :website }
  let(:website_member) { create :website_member, website: website, user: user }

  describe 'routing' do
    it 'routes to #websites/index' do
      expect(get('/website_members')).to route_to('website_members#index')
    end

    it 'routes to #webistes/destroy' do
      expect(delete("/website_members/#{website_member.id}")).to route_to('website_members#destroy', id: "#{website_member.id}")
    end
  end
end