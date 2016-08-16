class ApplicationController < ActionController::Base
  # include DeviseTokenAuth::Concerns::SetUserByToken
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  before_filter :set_gon
  before_filter :redirect_if_needed
  before_action :authenticate!
  before_action :set_raven_context

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to settings_url, :alert => exception.message
  end

  rescue_from CanCan::AuthorizationNotPerformed do |exception|
    redirect_to login_url, :alert => exception.message
  end

  def set_raven_context
    Raven.user_context({ id: current_user.id, email: current_user.email }) if current_user
  end

  protected

  def current_admin_user
    return current_user if current_user.admin?
  end

  def authenticate_admin_user!
    if current_user
      redirect_to errors_path, notice: 'Admin role required' if current_admin_user.nil?
    else
      redirect_to login_url
    end
  end

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

    @website ||= Website.find_by_id(session[:epiclogger_website_id])
  end
  helper_method :current_website

  def redirect_if_needed
    unless current_user
      url_session(request.url) unless [root_url,"#{root_url}unauthenticated", login_url, signup_url].include? request.url.split('?').first
    end
  end

  def set_website(website)
    return unless logged_in?
    return if website.nil?
    @website = website
    session[:epiclogger_website_id] = @website.id
  end

  def after_login_redirect(url_to_redirect = nil)
    redirect_to(url_to_redirect) && return unless url_to_redirect.nil?
    if current_website
      redirect_to errors_url
    else
      redirect_to website_wizard_path(:create)
    end
  end
  helper_method :after_login_redirect

  def url_session(url = nil)
    return session[:url] if url.nil?
    session[:url] = url
  end
end
