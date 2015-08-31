class Api::V1::InvitationsController < Api::V1::ApiController
  def create
  	token = SecureRandom.hex(10)
  	WebsiteMember.create( :invitation_token => token, :invitation_sent_at => Time.now.utc )
    UserMailer.member_invitation(params[:member][:website], params[:member][:email], token, current_member).deliver_now
  end
end