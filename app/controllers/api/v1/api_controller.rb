class Api::V1::ApiController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken
  # before_action :configure_permitted_parameters, if: :devise_controller?
  before_filter :set_websites_from_header
  layout nil
  before_action :authenticate_member!

  respond_to :json

  rescue_from ActiveRecord::RecordNotFound do |exception|
    # we save this exception as it is not an error if the restaurant or a parameter is not given
    render json: {:alert => exception.message}
  end

  def set_websites_from_header
    app_key = request.headers['HTTP_APP_KEY']
    app_id = request.headers['HTTP_APP_ID']
    @current_site ||= Website.find_by_app_id_and_app_key(app_id, app_key)
  end

  def current_site
    if params[:website_id] && current_member
      @current_site ||= current_member.websites.where("websites.id = ?", params[:website_id]).try(:first)
    end
  end

  # protected

  # def configure_permitted_parameters
  #   # devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:name, :confirm_success_url) }

  #   devise_parameter_sanitizer.for(:sign_up) << :name
  #   devise_parameter_sanitizer.for(:sign_up) << :confirm_success_url
  #   # devise_parameter_sanitizer.for(:account_update) << :operating_thetan
  #   # devise_parameter_sanitizer.for(:account_update) << :favorite_color
  # end
end
