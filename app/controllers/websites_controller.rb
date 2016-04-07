class WebsitesController < ApplicationController
  load_and_authorize_resource

  def index
    @websites = current_user.websites
  end

  def new
    @matched_platform = "python"
    @matched_tab = "django"
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
    if params[:platform] == 'rails_3' || params[:platform] == 'rails_4'
      #change the above if you change the view
      ##TODO we can find a better approach here
      @platform = "ruby"
      @tab = params[:platform]
    elsif params[:platform] == 'django'
      #same here
      @platform = "python"
      @tab = params[:platform]
    else
      @platform, @tab = params[:platform]
    end
    #find tabs array
    @platforms = tabs.find { |arr| arr.index(@tab) }
    # @tab_index = @platforms.index(@tab)
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

  # def steps
  #   ["add_website_step", "chose_platform_step", "configuration_step"]
  # end

  def platforms
    ["javascript", "node_js", "python", "php", "ruby", "java", "ios"]
  end

  def tabs
    array =  [["ios"], ["java", "java_util_logging", "java_4_j", "java_4_j_2", "logback"], ["javascript"], ["connect", "express", "node_js"], ["php"], ["django", "flask", "python", "tornado"], ["rails_3", "rails_4", "ruby", "sidekiq", "sinatra"]]
    return array
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
