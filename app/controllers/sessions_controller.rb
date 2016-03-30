class SessionsController < ApplicationController
  layout "landing"
  skip_before_action :authenticate_user

  def new
    @user = User.new
  end

  def create
    user = authenticate!
    redirect_to websites_url, notice: "Logged in"
  end

  def destroy
    logout
    redirect_to login_url
  end

  def unauthorized
    redirect_to login_url
  end
end
