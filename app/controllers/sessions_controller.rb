class SessionsController < ApplicationController
  layout "landing"
  skip_before_action :authenticate! #, only: [:create]

  def new
    after_login_redirect if logged_in?
    @user = User.new
  end

  def create
    user = User.find_by_email(user_params[:email])
    unless user.nil?
      if user.confirmation_token.nil?
        user = authenticate!(:password)
        set_website(user.default_website)
        after_login_redirect
      else
        redirect_to login_url, alert: "Confirm your email first"
      end
    end
  end

  def destroy
    logout
    redirect_to login_url
  end

  def unauthorized
    redirect_to login_url, alert: 'Your credentials are wrong'
  end

  protected
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :provider, :uid)
  end
end
