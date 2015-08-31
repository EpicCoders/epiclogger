class InvitationsController < ApplicationController
	def new
	end
	def show
    if !Member.find_by_email(params[:email]).present?
      signup_params = '?website_id=' + params[:id] + '&email=' + params[:email] + '&token=' + params[:token]
      redirect_to signup_url() + signup_params
    else
      WebsiteMember.where( invitation_token: params[:token] ).update_all( member_id: Member.find_by_email(params[:email]).id )
      redirect_to login_url()
    end
	end
end