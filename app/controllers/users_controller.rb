class UsersController < ApplicationController
  layout "landing"
  skip_before_action :authenticate!

  def index; end

  def new
    redirect_to websites_url if logged_in?

    @user = User.new
    gon.token = params[:id]
    gon.website_id = params[:website_id]
  end

  def create
    user = User.new(user_params)
    user.save

    authenticate!(:password)
    redirect_to new_website_url
  end

  def user_params
    params[:uid] = SecureRandom.hex(10)
    params[:provider] = 'email'
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :provider, :uid)
  end
end
