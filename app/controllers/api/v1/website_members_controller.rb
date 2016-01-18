class Api::V1::WebsiteMembersController < Api::V1::ApiController

  def index
    @members = current_site.website_members
  end

  def destroy
    @website_member = WebsiteMember.find(params[:id])
    @website_member.destroy()
    unless @website_member.errors.full_messages.blank?
      _not_allowed!(@website_member.errors.full_messages.first)
    end
    respond_to do |format|
      format.js {render inline: "location.reload();" }
    end
  end
end


