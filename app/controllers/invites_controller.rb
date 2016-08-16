class InvitesController < ApplicationController
  skip_before_action :authenticate!, only: :accept

  def create
    redirect_to(:new_invite, notice: 'User already invited') && return unless current_website.invites.where(email: invite_params[:email]).blank?
    invite = current_website.invites.new(invited_by_id: current_user.id, email: invite_params[:email])
    UserMailer.member_invitation(invite).deliver_later if invite.save
    redirect_to new_invite_url, notice: 'Email sent'
  end

  def new; end

  def accept
    @invite = Invite.find_by_token(params[:id])
    if !logged_in?
      if User.find_by_email(@invite.email).present?
        url_session(request.url)
        redirect_to login_url, notice: 'Login to continue'
      else
        redirect_to signup_url( token: params[:id] )
      end
    elsif @invite.email.casecmp(current_user.email) == 0
      @invite.accept(current_user)
      set_website(@invite.website)
      after_login_redirect
    else
      redirect_to :root, notice: 'The email address this invite was sent to does not match yours'
    end
  end

  private

  def invite_params
    params.require(:invite).permit(:email, :token)
  end
end
