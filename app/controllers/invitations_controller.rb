class InvitationsController < ApplicationController
  load_and_authorize_resource class: WebsiteMember
  def new
  end
  def show
    if @member = Member.find_by_email(params[:email])
      WebsiteMember.where( invitation_token: params[:id] ).update_all( member_id: @member.id )
      redirect_to login_url()
    else
      redirect_to signup_url(id: params[:id], email: params[:email])
    end
  end
end
