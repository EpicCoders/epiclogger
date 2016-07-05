class WebsiteMembersController < ApplicationController
	load_and_authorize_resource
  def index
    @website_members = current_website.website_members
  end

  def update
    @website_member.update_attributes(website_member_params)
    redirect_to installations_url(details_tab: 'notifications', main_tab: 'details'), notice: 'Successfully updated'
  end

  def destroy
    @website_member.destroy
    if @website_member.errors.full_messages.blank?
      redirect_to website_members_url
    else
      redirect_to website_members_url, notice: @website_member.errors.full_messages.join(', ')
    end
  end
  private

  def website_member_params
    params.require(:website_member).permit(:realtime, :frequent_event, :daily_reporting, :weekly_reporting)
  end
end
