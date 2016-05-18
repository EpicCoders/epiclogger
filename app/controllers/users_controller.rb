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

    authenticate!(:password) if user.save
    unless params[:invitation_token].blank?
      @website_member = WebsiteMember.find_by_invitation_token(params[:invitation_token])
      unless @website_member.nil?
        @website_member.update_attributes(user_id: user.id, role: 2)
        set_website(Website.find(@website_member.website_id))
      end
    end

    UserMailer.email_confirmation(user.confirmation_token).deliver_later
    user.update_attributes(confirmation_sent_at: Time.now)
    after_login_redirect
  end

  def confirm_account
    logout unless current_user.blank?
    @user = User.find_by_id_and_confirmation_token(params[:id], params[:token])
    unless @user.nil?
      @user.update_attributes(confirmation_token: nil, confirmed_at: Time.now.utc)
      redirect_to login_url
    else
      redirect_to login_url, alert: 'You confirmed your email once'
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :provider, :uid)
  end
end
