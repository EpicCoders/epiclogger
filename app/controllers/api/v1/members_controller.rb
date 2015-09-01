class Api::V1::MembersController < Api::V1::ApiController
  skip_before_action :authenticate_member!, only: [:create]
  def create
    WebsiteMember.find_by_invitation_token(params[:website_member][:token]).update_attributes(:member_id => Member.find_by_email(params[:website_member][:email]).id, :website_id => params[:website_member][:website_id])
  end
  def show
    @member = current_user
  end
end
