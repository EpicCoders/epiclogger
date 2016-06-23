class WebsitesController < ApplicationController
  load_and_authorize_resource

  def index
    @websites = current_user.websites
  end

  def update
    @website.update_attributes(website_params)
    redirect_to installations_url(details_tab: 'settings', main_tab: 'details'), notice: 'Website updated'
  end

  def destroy
    return false unless WebsiteMember.where(user_id: current_user.id, website_id: @website.id).first.role == "owner"
    @website.destroy
    if current_user.websites.blank?
      redirect_to website_wizard_url(:create)
    else
      set_website(current_user.websites.first)
      redirect_to websites_url
    end
  end

  def revoke
    @website.generate = true
    @website.save
    redirect_to installations_path(details_tab: 'api_keys', main_tab: 'details')
  end

  def change_current
    set_website(@website)
    redirect_to errors_url, notice: 'Website changed'
  end

  private

  def website_params
    params.require(:website).permit(:domain, :platform, :generate, :title, :id, :new_event, :frequent_event, :daily, :realtime)
  end
end
