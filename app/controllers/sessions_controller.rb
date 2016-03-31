class SessionsController < ApplicationController
  layout "landing"
  skip_before_action :authenticate! #, only: [:create]

  def new
    @user = User.new
  end

  def create
    user = authenticate!(:password)
    set_website(user.default_website)
    if current_website
      redirect_to errors_url, notice: "Logged in"
    else
      redirect_to new_website_url, notice: 'Logged in'
    end
  end

  def destroy
    logout
    redirect_to login_url
  end

  def unauthorized
    redirect_to login_url
  end
end
