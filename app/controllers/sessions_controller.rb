class SessionsController < ApplicationController
  layout "landing"
  skip_before_action :authenticate_member!

  def new 
    
  end

  def create
    user = warden.authenticate!
    redirect_to websites_url, notice: "Logged in"
  end

  def destroy
    warden.logout
    redirect_to login_url
  end
end
