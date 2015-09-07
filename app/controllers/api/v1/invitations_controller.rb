class Api::V1::InvitationsController < Api::V1::ApiController
  def create
    _not_allowed!('You are not the user of this website.') if current_site.nil?
    @website_member = current_site.website_members.create(invitation_sent_at: Time.now.utc, website_id: current_site.id)
    UserMailer.member_invitation(current_site.id, member_params[:email], @website_member.id, current_member.id).deliver_now
  end
  private
  def member_params
    params.require(:member).permit(:email)
  end
end