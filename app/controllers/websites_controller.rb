class WebsitesController < ApplicationController
  load_and_authorize_resource
  def index
    @websites = current_user.websites
  end
  def show; end
  def new; end
  def edit; end
  def change_current
    set_website(@website)
    redirect_to errors_url, notice: 'Website changed'
  end
end
