require 'rails_helper'

RSpec.describe GroupedIssuesController, type: :routing do
  let(:user) { create :user }
  let(:website) { create :website }
  let!(:website_member) { create :website_member, website: website, user: user }
  let(:group) { create :grouped_issue, website: website }

  describe 'routing' do
    it 'routes to #grouped_issues/index' do
      expect(get('/grouped_issues')).to route_to('grouped_issues#index')
    end

    it 'routes to #grouped_issues/show' do
      expect(get("/grouped_issues/#{group.id}")).to route_to('grouped_issues#show', id: "#{group.id}")
    end
  end
end