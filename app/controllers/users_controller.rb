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

    authenticate!(:password) if user.save
    unless params[:invitation_token].blank?
      @website_member = WebsiteMember.find_by_invitation_token(params[:invitation_token])
      unless @website_member.nil?
        @website_member.update_attributes(user_id: user.id, role: 2)
        set_website(Website.find(@website_member.website_id))
      end
    end

    after_login_redirect
  end

  private
  def user_params
    params[:user][:provider] = 'email'
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :provider, :uid)
  end
end
