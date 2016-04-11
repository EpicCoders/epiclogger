class WebsitesController < ApplicationController
  load_and_authorize_resource

  def index
    @websites = current_user.websites
  end

  def update
    @website.update_attributes(website_params)
  end

  def destroy
    @website.destroy
    respond_to do |format|
      format.js { render inline: 'location.reload();' } unless current_member.websites.blank?
      format.js { render inline: "location.href='#{website_wizard_path(:create)}';" } if current_member.websites.blank?
    end
  end

  def show; end

  private

  def website_params
    params.require(:websites).permit(:domain, :platform, :generate, :title, :id, :new_event, :frequent_event, :daily, :realtime)
  end
end
