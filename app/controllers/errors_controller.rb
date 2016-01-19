class ErrorsController < ApplicationController
  alias_method :current_user, :current_member
  load_and_authorize_resource class: Issue
  def show
    gon.error_id = params[:id]
  end
end
