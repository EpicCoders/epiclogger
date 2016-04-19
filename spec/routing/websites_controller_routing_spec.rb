require 'rails_helper'

RSpec.describe WebsitesController, type: :routing do
  let(:user) { create :user }
  let(:website) { create :website }
  let(:website_member) { create :website_member, website: website, user: user }

  describe 'routing' do
    it 'routes to #websites/index' do
      expect(get('/websites')).to route_to('websites#index')
    end

    it 'routes to #webistes/create' do
      expect(post("/websites")).to route_to('websites#create')
    end

    it 'routes to #webistes/new' do
      expect(get("/websites/new")).to route_to('websites#new')
    end

    it 'routes to #webistes/show' do
      expect(get("/websites/#{website.id}")).to route_to('websites#show', id: "#{website.id}")
    end

    it 'routes to #webistes/revoke' do
      expect(get(revoke_website_path(id: website.id))).to route_to('websites#revoke', id: "#{website.id}")
    end

    it 'routes to #webistes/wizard_install' do
      expect(get(wizard_install_website_path(id: website.id))).to route_to('websites#wizard_install', id: "#{website.id}")
    end

    it 'routes to #websites/update' do
      expect(put("/websites/#{website.id}")).to route_to('websites#update', id: "#{website.id}")
    end

    it 'routes to #websites/revoke' do
      expect(get(revoke_website_path(id: website.id))).to route_to('websites#revoke', id: "#{website.id}")
    end

    it 'routes to #webistes/destroy' do
      expect(delete("/websites/#{website.id}")).to route_to('websites#destroy', id: "#{website.id}")
    end
  end
end