require 'rails_helper'

describe Api::V1::MembersController, :type => :controller do
  let(:member) { create :member }
  let(:default_params) { {website_id: website.id, format: :json} }

  render_views # this is used so we can check the json response from the controller
end