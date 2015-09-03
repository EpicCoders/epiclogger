class Api::V1::MembersController < Api::V1::ApiController
  skip_before_action :authenticate_member!, only: [:create]

  def index
    @members = []
    current_site.website_members.each do |item|
      member = []
      member.push(Member.find(item.member_id), item.role)
      @members.push(member)
    end
  end

  def create
    WebsiteMember.find(params[:website_member][:website_member_id]).update_attributes(:member_id => Member.find_by_email(params[:website_member][:email]).id, :website_id => params[:website_member][:website_id])
  end

  def show
    @member = current_user
  end

  def destroy
    @member = Member.find(params[:id])
    @member.destroy()
  end
end
