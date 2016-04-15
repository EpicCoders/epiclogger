class WebsiteMembersController < ApplicationController
	load_and_authorize_resource
  def index
    @members = current_website.website_members
  end

  def destroy
    @website_member.destroy
    unless @website_member.errors.full_messages.blank?
      _not_allowed!(@website_member.errors.full_messages.first)
    end
    respond_to do |format|
      format.js {render inline: 'location.reload();' }
    end
  end
end
