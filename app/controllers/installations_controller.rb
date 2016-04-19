class InstallationsController < ApplicationController
  def index
    @website = current_website
    @main_tab = params[:main_tab] || "details"

    @details_tab = params[:details_tab] || "settings"
    @configuration_tab = params[:configuration_tab] || "all_platforms"
    @platform_tab = params[:platform_tab] || @configuration_tab

    @options = ["Javascript", "Python", "Django", "Flask", "Tornado", "Php", "Ruby", "Rails 3", "Rails 4", "Sinatra", "Sidekiq", "Node js", "Express", "Connect", "Java", "Java util logging", "Log4j", "Log4j2", "Logback", "Ios"]
  end
end
