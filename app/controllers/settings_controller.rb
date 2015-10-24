class SettingsController < ApplicationController
  def index
  	gon.keys = []
  	Website.all.each do |website|
  		gon.keys.push(website.app_key)
    end
  end
end
