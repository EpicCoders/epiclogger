class WebsiteMembersController < ApplicationController
	load_and_authorize_resource
  def index
    @website_members = current_website.website_members
  end

  def destroy
    @website_member.destroy
    if @website_member.errors.full_messages.blank?
	    redirect_to website_members_url
	  else
	    redirect_to website_members_url, notice: @website_member.errors.full_messages.join(', ')
	  end
  end
end
