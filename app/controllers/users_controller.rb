class UsersController < ApplicationController
  layout 'landing', :only => [:new, :create]
  load_and_authorize_resource only: [:edit, :update]
  skip_before_action :authenticate!

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

    if user.save
      authenticate!(:password)
      set_website(Invite.find_by_token(params[:token]).website) if user.accept(params[:token])
      UserMailer.email_confirmation(user.confirmation_token).deliver_later
      user.update_attributes(confirmation_sent_at: Time.now)
      after_login_redirect
    end
  end

  def confirm_account
    logout unless current_user.blank?
    @user = User.find_by_id_and_confirmation_token(params[:id], params[:token])
    unless @user.nil?
      @user.update_attributes(confirmation_token: nil, confirmed_at: Time.now.utc)
      redirect_to login_url
    else
      redirect_to root_url, alert: 'You confirmed your email once'
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :provider, :uid)
  end
end
