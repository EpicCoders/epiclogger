class ApplicationController < ActionController::Base
  # include DeviseTokenAuth::Concerns::SetUserByToken
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  before_filter :set_gon
  before_action :authenticate!

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  rescue_from CanCan::AuthorizationNotPerformed do |exception|
    redirect_to login_url, :alert => exception.message
  end

  protected

  def set_gon
    info = { env: Rails.env }
    # this code below seems useless
    # token = (params[:token].nil?) ? cookies[:epiclogger_token] : params[:token]
    info[:controller] = controller_name
    info[:action] = action_name
    gon.push(info)
  end

  def current_website
    return unless logged_in?
    @website ||= Website.find(session[:epiclogger_website_id])
  end

  def set_website(website)
    return unless logged_in?
    @website = website
    session[:epiclogger_website_id] = @website.id
  end
end
