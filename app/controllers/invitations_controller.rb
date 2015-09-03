class InvitationsController < ApplicationController
  def new
  end
  def show
    if @member = Member.find_by_email(params[:email])
      WebsiteMember.where( invitation_token: params[:token] ).update_all( member_id: @member.id )
      redirect_to login_url()
    else
      redirect_to signup_url(website_id: params[:id], email: params[:email], token: params[:token])
    end
  end
end
