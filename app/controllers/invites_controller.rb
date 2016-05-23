class InvitesController < ApplicationController
  skip_before_action :authenticate!, only: :accept

  def create
    begin
      unless Invite.where('email = ? AND website_id = ? AND invited_by_id =?', invite_params[:email], current_website.id, current_user.id).blank?
        raise "Duplicate invites"
      end
      invite = current_website.invites.new(invited_by_id: current_user.id, email: invite_params[:email])
      UserMailer.member_invitation(invite.id).deliver_later if invite.save
      redirect_to new_invite_url, notice: 'Email sent'

    rescue Exception => e
      redirect_to(:action => 'new', notice: e.message)
    end
  end

  def new; end

  def show
    @invite = Invite.find_by_token(params[:token])
    #we create new website member in case user already has an account
    user = User.find_by_email(@invite.email)
    unless user.blank?
      user.website_members.create(website_id: @invite.website_id)
      redirect_to root_url(), notice: "You are now a member of #{@invite.website.domain}"
    else
      logout unless current_website.nil?
      redirect_to signup_url(token: params[:token], email: @invite.email)
    end
  end

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
