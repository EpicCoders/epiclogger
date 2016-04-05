class UsersController < ApplicationController
  layout "landing"
  skip_before_action :authenticate!

  def index; end

  def new
    @user = User.new
    gon.token = params[:id]
    gon.website_id = params[:website_id]
  end

  def create
    @user = User.new(user_params)
    @user.save
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
