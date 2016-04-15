class InstallationsController < ApplicationController
  def index
    @website = current_website
    @main_tab = assign_variables(:main_tab, "details")

    @configuration_tab = assign_variables(:configuration_tab, "all_platforms")
    @platform_tab = params[:platform_tab] || @configuration_tab
    @details_tab = assign_variables(:details_tab, "settings")
  end

  def assign_variables(tab, default)
    session[tab] = params[tab] if params[tab].present?
    return session[tab] || default
  end
end
