class InstallationsController < ApplicationController
  alias_method :current_user, :current_member
  load_and_authorize_resource class: Website
  def index
  end
  def show
  end
end
