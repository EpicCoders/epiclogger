class Api::V1::WebsiteMembersController < Api::V1::ApiController
  load_and_authorize_resource
  def index; end

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
