require 'rails_helper'

RSpec.describe ResetPasswordController, type: :routing do
  let(:user) { create :user, reset_password_token: 'vJq2UGPUDBZYcO7RiuxkAw' }

  describe 'routing' do
    it 'routes to #reset_password/new' do
      expect(get('/forgot_password')).to route_to('reset_password#new')
    end

    it 'routes to #reset_password/create' do
      expect(post('/forgot_password')).to route_to('reset_password#create')
    end

    it 'routes to #reset_password/edit' do
    	expect(get(reset_password_path(id: user.reset_password_token))).to route_to('reset_password#edit', id: "#{user.reset_password_token}")
    end

    it 'routes to #reset_password/update' do
    	expect(patch(reset_password_path(id: user.reset_password_token))).to route_to('reset_password#update', id: "#{user.reset_password_token}")
    end
  end
end