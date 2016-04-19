require 'rails_helper'

RSpec.describe WebsiteWizardController, type: :routing do
  let(:user) { create :user }
  let(:website) { create :website }
  let(:website_member) { create :website_member, website: website, user: user }
  let(:subscriber) { create :subscriber, website: website }

  describe 'routing' do
    it 'routes to #website_wizard/index' do
      expect(get("/website_wizard")).to route_to('website_wizard#index')
    end

    it 'routes to #website_wizard/create' do
      expect(post("/website_wizard")).to route_to('website_wizard#create')
    end

    it 'routes to #website_wizard/new' do
      expect(get("/website_wizard/new")).to route_to('website_wizard#new')
    end

    it 'routes to #website_wizard/show' do
      expect(get("/website_wizard/#{website.id}")).to route_to('website_wizard#show', id: "#{website.id}")
    end

    it 'routes to #website_wizard/edit' do
      expect(get(edit_website_wizard_path(id: user.id))).to route_to('website_wizard#edit', id: "#{user.id}")
    end

    it 'routes to #website_wizard/update' do
      expect(put("/website_wizard/#{website.id}")).to route_to('website_wizard#update', id: "#{website.id}")
    end

    it 'routes to #website_wizard/destroy' do
      expect(delete("/website_wizard/#{website.id}")).to route_to('website_wizard#destroy', id: "#{website.id}")
    end
  end
end