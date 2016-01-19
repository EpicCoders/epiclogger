class WebsiteMembersController < ApplicationController
  alias_method :current_user, :current_member
  load_and_authorize_resource
  def index
  end
end
