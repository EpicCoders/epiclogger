class WebsiteMembersController < ApplicationController
	load_and_authorize_resource
  def index
    @website_members = current_website.website_members.where("user_id IS NOT NULL")
  end

  def destroy
    @website_member.destroy
    return false unless @website_member.errors.full_messages.blank?
    redirect_to website_members_path, notice: 'Member removed'
  end
end
