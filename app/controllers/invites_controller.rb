class InvitesController < ApplicationController
  skip_before_action :authenticate!, only: :accept

  def create
    redirect_to(:new_invite, notice: 'User already invited') && return unless current_website.invites.where(email: invite_params[:email]).blank?
    invite = current_website.invites.new(invited_by_id: current_user.id, email: invite_params[:email])
    UserMailer.member_invitation(invite.id).deliver_later if invite.save
    redirect_to new_invite_url, notice: 'Email sent'
  end

  def new; end

  def accept
    @invite = Invite.find_by_token(params[:id])
    if !logged_in?
      # we redirect to signup url because we are not logged in
      redirect_to signup_url( token: params[:id] )
    elsif @invite.email.casecmp(current_user.email) == 0
      @invite.accept(current_user)
      set_website(@invite.website)
      # it will redirect to errors url because we set the website for the user
      after_login_redirect
    else
      # it will redirect to create website wizard because we don't sent it
      after_login_redirect
    end
  end

  private

  def invite_params
    params.require(:invite).permit(:email, :token)
  end
end
