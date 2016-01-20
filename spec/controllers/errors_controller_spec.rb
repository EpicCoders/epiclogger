require 'rails_helper'

RSpec.describe ErrorsController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    it "returns http success" do
      issue = create :issue, id: 1
      get :show, {id: issue.id}
      expect(response).to have_http_status(:success)
    end
  end

end
