class InvitesController < ApplicationController
  def create
    begin
      unless Invite.where('email = ? AND website_id = ? AND invited_by_id =?', invite_params[:email], current_website.id, current_user.id).blank?
        raise "Duplicate invites"
      end
      invite = current_website.invites.new(invited_by_id: current_user.id, email: invite_params[:email])
      UserMailer.member_invitation(invite.id).deliver_later if invite.save
      redirect_to new_invites_url, notice: 'Email sent'

    rescue Exception => e
      redirect_to(:action => 'new', notice: e.message)
    end
  end

  def new; end

  def show
    if @user = User.find_by_email(params[:email])
      WebsiteMember.where( invitation_token: params[:id] ).update_all( user_id: @user.id )
      redirect_to login_url()
    else
      logout
      redirect_to signup_url(id: params[:id], email: params[:email])
    end
  end

  private

  def invite_params
    params.require(:invite).permit(:email, :token)
  end
end
