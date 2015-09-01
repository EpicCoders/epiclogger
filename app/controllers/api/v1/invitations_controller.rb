class Api::V1::InvitationsController < Api::V1::ApiController
  def create
    website_member = WebsiteMember.new()
    website_member.invitation_sent_at = Time.now.utc
    website_member.invitation_token = loop do
      token = SecureRandom.hex(10)
      break token unless WebsiteMember.exists?(invitation_token: token)
    end
    website_member.save
    UserMailer.member_invitation(member_params[:website_id], member_params[:email], website_member.invitation_token, current_member.id).deliver_now
  end
  private
  def member_params
    params.require(:member).permit(:email, :website_id)
  end
end