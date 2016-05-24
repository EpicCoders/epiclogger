class UsersController < ApplicationController
  layout 'landing', :only => [:new, :create]
  load_and_authorize_resource only: [:edit, :update]
  skip_before_action :authenticate!
  attr_accessor :redirect_url

  def index; end

  def edit; end

  def update
    @user.update_attributes(user_params)
    redirect_to edit_user_path(@user), notice: 'User updated'
  end

  def new
    after_login_redirect if logged_in?

    @user = User.new
    gon.token = params[:id]
    gon.website_id = params[:website_id]
  end

  def create
    user = User.new(user_params)

    if user.save!
      authenticate!(:password)
      user.send_confirmation
    end
    redirect_url = accept_invite_url(params[:token]) if params[:token].present?
    after_login_redirect(redirect_url)
  end

  def confirm_account
    user = User.find_by_id_and_confirmation_token(params[:id], params[:token])
    logout if logged_in? && user
    if user.nil?
      redirect_to root_url, alert: 'You confirmed your email once'
    else
      user.update_attributes(confirmation_token: nil, confirmed_at: Time.now.utc)
      redirect_to login_url, notice: "Account confirmed"
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :provider, :uid)
  end
end
