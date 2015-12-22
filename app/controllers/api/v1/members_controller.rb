class Api::V1::MembersController < Api::V1::ApiController
  skip_before_action :authenticate_member!, only: [:create]

  def index
    @members = current_site.website_members
  end

  def create
    member = Member.find_by_email(website_member[:email])
    if params[:website_member]['token'].present?
      WebsiteMember.find_by_invitation_token(website_member[:token]).update_attributes(:member_id => member.id)
    end
  end

  def show
    @member = current_member
  end

  def destroy
    if current_member.is_owner_of?(current_site)
      @website_member = WebsiteMember.find(params[:id])
      @website_member.destroy()
    else
      _not_allowed!("Owner access required.")
    end
  end

  private
  def website_member
    params.require(:website_member).permit(:token, :email, :website_id)
  end
end
