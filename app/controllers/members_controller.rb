class MembersController < ApplicationController
  layout "landing", only: [:new, :create]
  skip_before_action :authenticate_member!

  def index
  end

  def new
    gon.website_member_id = params[:website_member_id]
    gon.website_id = params[:website_id]
  end

  def create
  end
end
