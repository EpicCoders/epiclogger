class SessionsController < ApplicationController
  layout "landing"
  skip_before_action :authenticate! #, only: [:create]

  def new
    after_login_redirect if logged_in?
    @user = User.new
  end

  def create
    user = authenticate!(:password)
    set_website(user.default_website)
    after_login_redirect
  end

  def destroy
    logout
    redirect_to login_url
  end

  def unauthorized
    url_session(request.original_url)
    redirect_to login_url, alert: 'Your credentials are wrong or your email is not confirmed'
  end

  protected
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :provider, :uid)
  end
end
