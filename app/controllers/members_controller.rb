class MembersController < ApplicationController
  layout "landing", only: [:new, :create]
  skip_before_action :authenticate_member!

  def index
  end

  def edit
  end

  def new
    gon.token = params[:id]
    gon.website_id = params[:website_id]
  end

  def create
  end
end
