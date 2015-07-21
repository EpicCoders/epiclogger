class ErrorsController < ApplicationController
  def index
  end

  def show
    gon.error_id = params[:id]
  end

  def edit
    gon.error_id = params[:id]
  end
end
