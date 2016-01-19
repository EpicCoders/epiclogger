class WebsitesController < ApplicationController
  alias_method :current_user, :current_member
  load_and_authorize_resource
  def index
  end

  def show
  end

  def new
  end

  def edit
  end
end
