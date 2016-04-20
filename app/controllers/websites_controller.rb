class WebsitesController < ApplicationController
  load_and_authorize_resource

  def index
    @websites = current_user.websites
  end

  def update
    @website.update_attributes(website_params)
    respond_to do |format|
      format.js { render inline: 'location.reload();' }
    end
  end

  def destroy
    return false unless WebsiteMember.where(user_id: current_user.id, website_id: @website.id).first.role == "owner"
    @website.destroy
    respond_to do |format|
      unless current_user.websites.blank?
        set_website(current_user.websites.first)
        format.js { render inline: 'location.reload();' }
      end
      format.js { render inline: "location.href='#{website_wizard_path(:create)}';" } if current_user.websites.blank?
    end
  end

  def revoke
    @website.generate = true
    @website.save
    redirect_to "/installations?details_tab=api_keys&main_tab=details"
  end

  def show; end

  def change_current
    set_website(@website)
    redirect_to errors_url, notice: 'Website changed'
  end

  private

  def website_params
    params.require(:website).permit(:domain, :platform, :generate, :title, :id, :new_event, :frequent_event, :daily, :realtime)
  end
end
