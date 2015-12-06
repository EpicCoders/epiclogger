class Api::V1::WebsitesController < Api::V1::ApiController
  def index
    @websites = current_member.websites
  end

  def create
    website_exists = WebsiteMember.where("member_id = ?", current_member.id).joins(:website).where("domain = ?", website_params["domain"])
    if website_exists.blank?
      @website = Website.create( domain: website_params[:domain], title: website_params[:title] )
      @notification = Notification.create(:website_member_id => @website_member.id)
      @website.website_members.create( notification_id: @notification.id, member_id: current_member.id, role: WebsiteMember.role.find_value(:owner).value )
    else
      _not_allowed!
    end
  end

  def show
    @website = current_member.websites.find(params[:id])
  end

  def update
    @website = current_member.websites.find(website_params[:id])
    @website.update_attributes(website_params)
  end

  def destroy
    @website = current_member.websites.find(params[:id])
    @website.destroy()
  end

  private
		def website_params
			params.require(:website).permit(:domain, :title, :id)
		end
end
