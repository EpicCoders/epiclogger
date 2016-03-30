class UsersController < ApplicationController
  layout "landing", only: [:new, :create]
  # what why??
  skip_authorization_check :only => [:new, :create]

  def index; end

  def new
    gon.token = params[:id]
    gon.website_id = params[:website_id]
  end

  def create; end
end
