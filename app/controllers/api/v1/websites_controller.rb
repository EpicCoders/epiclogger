class Api::V1::WebsitesController < Api::V1::ApiController
  skip_before_action :authenticate_member!, except: [:index]

  def index
    @websites = current_member.websites
  end

  def create
    @website = Website.create(domain: website_params[:domain], title: website_params[:title], member_id: current_member.id)
  end

  def show
    @website = Website.find_by_id(params[:id])
  end

  def destroy
    @website = Website.find(parmas[:id])
    @website.destroy()
  end

  private
		def website_params
			params.require(:website).permit(:domain, :title, :id, :app_id, :app_key)
		end
end
