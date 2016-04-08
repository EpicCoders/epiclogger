class WebsitesController < ApplicationController
  load_and_authorize_resource

  def index
    @websites = current_user.websites
  end

  def new
    got_to_step(0)
  end

  def create
    url = URI.parse(website_params[:domain])
    @website = current_user.websites.create!(domain: "#{url.scheme}://#{url.host}", title: website_params[:title])
    if @website.persisted?
      set_website(@website)
      got_to_step(1)
    end
  end

  def wizard_install
    if params[:back].present?
      got_to_step(1)
      return
    end
    if params[:tab].present?
      attribute = "#{params[:platform].humanize}(#{params[:tab].humanize})"
      @tab, gon.platform = params[:tab], params[:tab]
    else
      attribute = params[:platform].humanize
      @tab, gon.platform = params[:platform], params[:platform]
    end
    @rendered = "#{params[:platform]}_tab"
    current_website.update_attributes(platform: attribute)
    got_to_step(2)
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

  def got_to_step(step)
    @current_step = steps[step]
    @step = steps.index(@current_step)
    render "new"
  end

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
