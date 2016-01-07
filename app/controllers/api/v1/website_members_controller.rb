class Api::V1::WebsiteMembersController < Api::V1::ApiController

  def index
    @members = current_site.website_members
  end

  def destroy
    if current_member.is_owner_of?(current_site)
      @website_member = WebsiteMember.find(params[:id])
      _not_allowed!("Owner cant be removed.") if @website_member.role == 'owner'
      @website_member.destroy()
      respond_to do |format|
        format.js {render inline: "location.reload();" }
      end
    else
      _not_allowed!("Owner access required.")
    end
  end
end


