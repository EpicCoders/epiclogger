class Api::V1::WebsitesController < Api::V1::ApiController
  load_and_authorize_resource
  def index
    @websites = current_member.websites
  end

  def create
    url = URI.parse(website_params[:domain])
    @website = current_member.websites.create!(domain: "#{url.scheme}://#{url.host}", title: website_params[:title])
  rescue => e
    _not_allowed! e.message
  end

  def show; end

  def update
    @website.update_attributes(website_params)
  end

  def destroy
    @website.destroy
    respond_to do |format|
      format.js { render inline: 'location.reload();' } unless current_member.websites.blank?
      format.js { render inline: "location.href='#{new_website_path}';" } if current_member.websites.blank?
    end
  end

  private

  def website_params
    params.require(:website).permit(:member_id, :domain, :platform, :generate, :title, :id, :new_event, :frequent_event, :daily, :realtime)
  end
end
