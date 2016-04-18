class AuthController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:success]
  skip_before_action :authenticate!

  def create
  end

  def success
    unless authenticated?
      user = User.find_by_provider_and_uid(provider, auth_hash['uid']) || User.create_with_omniauth(auth_hash)
      authenticate!(provider.to_sym) if user
    end
    if integration_session
      # create integration
      begin
        Integration.transaction do
          @integration = Integration.find(integration_session['id'])
          @integration.save!
        end
      rescue
        redirect_to @integration
        redirect_to new_integration_url(@integration, type: @integration.type)
      ensure
        session['integration'] = nil
      end
    else
      after_login_redirect
    end
  end

  def failure

  end

  private

  def auth_hash
    request.env['omniauth.auth']
  end

  def provider
    auth_hash['provider']
  end

  def integration_session
    session['integration']
  end
end
