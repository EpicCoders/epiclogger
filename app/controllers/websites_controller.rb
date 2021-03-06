class WebsitesController < ApplicationController
  load_and_authorize_resource

  def index
    @websites = current_user.websites
  end

  def update
    if @website.update_attributes(website_params)
      redirect_to settings_url, notice: 'Website updated'
    else
      redirect_to settings_url, notice: @website.errors.full_messages.join(', ')
    end
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
    redirect_to settings_path(details_tab: 'api_keys', main_tab: 'details')
  end

  def change_current
    set_website(@website)
    redirect_to errors_url, notice: 'Website changed'
  end

  private

  def website_params
    params.require(:website).permit(:domain, :platform, :generate, :title, :origins)
  end
end
