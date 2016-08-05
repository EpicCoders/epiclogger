class WebsiteMembersController < ApplicationController
	load_and_authorize_resource
  def index
    @website_members = current_website.website_members.where.not(user_id: current_user.id)
  end

  def update
    @website_member.update_attributes(website_member_params)
    redirect_to settings_url(details_tab: 'notifications', main_tab: 'details'), notice: 'Successfully updated'
  end

  def change_role
    current_website_member = WebsiteMember.find_by_user_id_and_website_id(current_user.id, current_website.id)
    if current_website_member.role.owner?
      @website_member.update_attributes(website_member_role_params)
      flash[:alert] = "Role updated"
      render json: @website_member
    end
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

  def website_member_role_params
    params.require(:website_member_role).permit(:role)
  end
end
