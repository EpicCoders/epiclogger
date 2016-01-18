class Api::V1::ApiController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken
  # before_action :configure_permitted_parameters, if: :devise_controller?
  layout nil
  before_action :authenticate_member!

  respond_to :json

  rescue_from ActiveRecord::RecordNotFound do |exception|
    # we save this exception as it is not an error if the restaurant or a parameter is not given
    render json: {:alert => exception.message}
  end

  rescue_from Epiclogger::Errors::NotAllowed do |e|
    render json: {errors: e.message}, status: e.status
  end

  def current_ability
    @current_ability ||= ::ApiAbility.new(current_member)
  end

  # rescue_from CanCan::AccessDenied do |exception|
    
  # end

  def _not_allowed! message = "Not Authorized", status = 401
    raise Epiclogger::Errors::NotAllowed.new(status), message
  end

  def current_site
    if params[:website_id] && current_member
      @current_site ||= current_member.websites.where("websites.id = ?", params[:website_id]).try(:first)
    else
      @current_site ||= Website.find_by_app_id_and_app_key(params[:id], params[:sentry_key])
      # @current_site ||= Website.find_by_app_id_and_app_key(params["app_id"],params["app_key"])
    end
  end

  def current_notification
    current_site.notification
  end

  def current_group
    @current_group ||= current_site.grouped_issues.find(params[:group_id])
  end
end
