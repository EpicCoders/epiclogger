class UsersController < ApplicationController
  layout "landing"
  skip_before_action :authenticate!

  def index; end

  def new
    after_login_redirect if logged_in?

    @user = User.new
    gon.token = params[:id]
    gon.website_id = params[:website_id]
  end

  def create
    user = User.new(user_params)
    user.save

    authenticate!(:password)
    after_login_redirect
  end

  private
  def user_params
    params[:uid] = SecureRandom.hex(10)
    params[:provider] = 'email'
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :provider, :uid)
  end
end
