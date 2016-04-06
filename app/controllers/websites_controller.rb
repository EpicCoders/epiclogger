class WebsitesController < ApplicationController
  load_and_authorize_resource

  def index
    @websites = current_user.websites
  end

  def next_step
    @current_step = steps[@step + 1]
  end

  def previous_step
    @current_step = steps[@step -1]
  end

  def new
    @key = "dasdaio209123me83n3u8"
    @step = steps.index(steps.first) + 1
    @fist_step = steps.first
    @current_step = steps[@step]
    render "new"
  end

  def create
    url = URI.parse(website_params[:domain])
    @website = current_user.websites.create!(domain: "#{url.scheme}://#{url.host}", title: website_params[:title])
    if @website.persisted?
      @step = steps.index(steps.second)
      @current_step = steps[@step]
    end
  end

  def wizard_install
  end

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

  def show; end

  def steps
    ["add_website_step", "chose_platform_step", "configuration_step"]
  end
  def change_current
    set_website(@website)
    redirect_to errors_url, notice: 'Website changed'
  end

  private

  def website_params
    params.require(:websites).permit(:domain, :platform, :generate, :title, :id, :new_event, :frequent_event, :daily, :realtime)
  end
end
