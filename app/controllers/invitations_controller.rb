class InvitationsController < ApplicationController
  def create
    if current_website.nil? || validate_email(user_params[:email])
      respond_to do |format|
        format.js { render inline: 'location.reload();' }
      end
      return false
    end
    @website_member = current_website.website_members.create(invitation_sent_at: Time.now.utc, website_id: current_website.id)
    UserMailer.member_invitation(current_website.id, user_params[:email], @website_member.id, current_user.id).deliver_later
  end

  def new; end

  def show
    if @user = User.find_by_email(params[:email])
      WebsiteMember.where( invitation_token: params[:id] ).update_all( user_id: @user.id )
      redirect_to login_url()
    else
      redirect_to signup_url(id: params[:id], email: params[:email])
    end
  end

  def validate_email(email)
    (/\A[\w\u00C0-\u017F\-]+(\.[\w\u00C0-\u017F\-]+)?@[\w\u00C0-\u017F\-]+\.[\w]{2,6}$/.match email).nil?
  end

  private

  def user_params
    params.require(:user).permit(:email)
  end
end
