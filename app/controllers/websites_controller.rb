class WebsitesController < ApplicationController
  load_and_authorize_resource

  def index
    @websites = current_user.websites
  end

  def new
    gon.platform = "node_js"
    @rendered = platform_tabs[3]
    @step = steps.index(steps.first) + 2
    @current_step = steps[@step]
    render "new"
  end

  def create
    url = URI.parse(website_params[:domain])
    @website = current_user.websites.create!(domain: "#{url.scheme}://#{url.host}", title: website_params[:title])
    if @website.persisted?
      @step += 1
      @current_step = steps[@step]
    end
  end

  def wizard_install
    if params[:picked] == 'rails_3' || params[:picked] == 'rails_4'
      ##TODO we can find a better approach here
      @platform = "ruby"
      @tab = params[:picked]
    elsif params[:picked] == 'django'
      @platform = "python"
      @tab = params[:picked]
    else
      @platform, @tab = params[:picked]
    end
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

  def platform_tabs
    ["ios_tab", "java_tab", "javascript_tab", "node_js_tab", "php_tab", "python_tab", "ruby_tab"]
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
