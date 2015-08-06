class Api::V1::WebsitesController < Api::V1::ApiController
  skip_before_action :authenticate_member!, except: [:index]

  def index
    @websites = current_member.websites
  end

  def create
  end
end
