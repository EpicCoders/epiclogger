class Api::V1::WebsitesController < Api::V1::ApiController
  def index
    @websites = current_member.websites
  end

  def create
    @website = Website.create( domain: website_params[:domain], title: website_params[:title] )
    @website.website_members.create( member_id: current_member.id, role: WebsiteMember.role.find_value(:owner).value )
  end

  def show
    @website = current_member.websites.find(params[:id])
  end

  def update
    @website = Website.find(website_params[:id])
    @website.update_attributes(app_key: website_params[:app_key])
  end

  def destroy
    @website = current_member.websites.find(params[:id])
    @website.destroy()
  end

  private
		def website_params
			params.require(:website).permit(:domain, :website_id, :title, :id, :app_id, :app_key)
		end
end
