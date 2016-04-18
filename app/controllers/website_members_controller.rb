class WebsiteMembersController < ApplicationController
	load_and_authorize_resource
  def index
    @members = current_website.website_members
  end

  def destroy
    @website_member.destroy
    return false unless @website_member.errors.full_messages.blank?
    respond_to do |format|
      format.js {render inline: 'location.reload();' }
    end
  end
end
