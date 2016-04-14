class InvitationsController < ApplicationController
  def new; end

  def show
    if @user = User.find_by_email(params[:email])
      WebsiteMember.where( invitation_token: params[:id] ).update_all( user_id: @user.id )
      redirect_to login_url()
    else
      redirect_to signup_url(id: params[:id], email: params[:email])
    end
  end
end
