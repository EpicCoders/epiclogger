class InstallationsController < ApplicationController
  def index
    @website = current_website
    session[:main_tab] = params[:main_tab] if params[:main_tab].present?
    @main_tab = session[:main_tab] || "details"

    session[:configuration_tab] = params[:configuration_tab] if params[:configuration_tab].present?
    @configuration_tab = session[:configuration_tab] || "all_platforms"
    @platform_tab = params[:platform_tab] || @configuration_tab

    @details_tab = params[:details_tab] || "settings"
  end
end
