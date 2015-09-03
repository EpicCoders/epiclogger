class Api::V1::InvitationsController < Api::V1::ApiController
  def create
    @website_member = WebsiteMember.create(invitation_sent_at: Time.now.utc)
    UserMailer.member_invitation(member_params[:website_id], member_params[:email], @website_member.id, current_member.id).deliver_now
  end
  private
  def member_params
    params.require(:member).permit(:email, :website_id)
  end
end