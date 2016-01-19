class ErrorsController < ApplicationController
  def show
    gon.error_id = params[:id]
  end
end
