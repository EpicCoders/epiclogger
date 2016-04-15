class InstallationsController < ApplicationController
  def index
    @website = current_website
    @main_tab = params[:main_tab] || "details"
    @details_tab = params[:details_tab] || "settings"
  end
end
