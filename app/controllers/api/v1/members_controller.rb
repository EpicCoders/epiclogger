class Api::V1::MembersController < Api::V1::ApiController
  skip_before_action :authenticate_member!, only: [:create]
  def create
    WebsiteMember.find(params[:website_member][:website_member_id]).update_attributes(:member_id => Member.find_by_email(params[:website_member][:email]).id, :website_id => params[:website_member][:website_id])
  end
  def show
    @member = current_user
  end
end
