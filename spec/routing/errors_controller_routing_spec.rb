require 'rails_helper'

RSpec.describe ErrorsController, type: :routing do
  let(:user) { create :user }
  let(:website) { create :website }
  let(:website_member) { create :website_member, website: website, user: user }
  let(:group) { create :grouped_issue, website: website }

  describe 'routing' do
    it 'routes to #errors/index' do
      expect(get('/errors')).to route_to('errors#index')
    end

    it 'routes to #errors/show' do
      expect(get("/errors/#{group.id}")).to route_to('errors#show', id: "#{group.id}")
    end

    it 'routes to #errors/update' do
      expect(put("/errors/#{group.id}")).to route_to('errors#update', id: "#{group.id}")
    end

    it 'routes to #errors/notify_subscribers' do
      expect(post(notify_subscribers_error_path(id: group.id))).to route_to('errors#notify_subscribers', id: "#{group.id}")
    end

    it 'routes to #errors/resolve' do
      expect(put(resolve_error_path(id: group.id))).to route_to('errors#resolve', id: "#{group.id}")
    end
  end
end