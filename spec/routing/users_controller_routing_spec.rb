require 'rails_helper'

RSpec.describe UsersController, type: :routing do
  let(:user) { create :user }
  let(:website) { create :website }
  let(:website_member) { create :website_member, website: website, user: user }

  describe 'routing' do
    it 'routes to #errors/index' do
      expect(get('/users')).to route_to('users#index')
    end

    it 'routes to #users/edit' do
      expect(get(edit_user_path(id: user.id))).to route_to('users#edit', id: "#{user.id}")
    end
  end
end