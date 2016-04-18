class InstallationsController < ApplicationController
  def index
    @website = current_website
    @main_tab = assign_variables(:main_tab, "details")

    @details_tab = assign_variables(:details_tab, "settings")
    @configuration_tab = assign_variables(:configuration_tab, "all_platforms")
    @platform_tab = params[:platform_tab] || @configuration_tab

    @options = ["Javascript", "Python", "Django", "Flask", "Tornado", "Php", "Ruby", "Rails 3", "Rails 4", "Sinatra", "Sidekiq", "Node js", "Express", "Connect", "Java", "Java util logging", "Log4j", "Log4j2", "Logback", "Ios"]
  end

  def assign_variables(tab, default)
    session[tab] = params[tab] if params[tab].present?
    return session[tab] || default
  end
end
