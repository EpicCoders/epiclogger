class ErrorsController < ApplicationController
  load_and_authorize_resource class: Issue
  def show
    gon.error_id = params[:id]
  end
end
