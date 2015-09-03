class Api::V1::WebsitesController < Api::V1::ApiController
  def index
    @websites = current_member.websites
  end

  def create
    @website = current_member.websites.create( domain: website_params[:domain], title: website_params[:title], member_id: current_member.id )
    WebsiteMember.create( member_id: current_member.id, website_id: @website.id, role: WebsiteMember.role.find_value(:owner).value )
  end

  def show
    @website = current_member.websites.find(params[:id])
  end

  def destroy
    @website = current_member.websites.find(params[:id])
    @website.destroy()
  end

  private
		def website_params
			params.require(:website).permit(:domain, :title, :id, :app_id, :app_key)
		end
end
