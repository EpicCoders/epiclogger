class Api::V1::WebsitesController < Api::V1::ApiController
  def index
    @websites = current_member.websites
  end

  def create
    website = WebsiteMember.where("member_id = ?", current_member.id).joins(:website).where("domain = ?", website_params[:domain])
    if website.blank?
      @website = current_member.websites.create!( domain: website_params[:domain], title: website_params[:title] )
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
    respond_to do |format|
      format.js {render inline: "location.reload();" }
    end
  end

  private
    def website_params
      params.require(:website).permit(:domain, :generate, :title, :id)
    end
end
