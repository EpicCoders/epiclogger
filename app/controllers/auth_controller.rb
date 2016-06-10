class AuthController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:success]
  skip_before_action :authenticate!, only: [:success]

  def create
    unless Integrations.supports?(integration_params[:provider])
      redirect_to :integrations, error: 'Invalid integration'
      return
    end

    @integration = Integration.new(integration_params)
    @integration.website = current_website
    if @integration.valid?
      session['integration'] = integration_params
      redirect_to "/auth/#{@integration.provider}"
    else
      render template: 'integrations/new'
    end
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
          @website = Website.find_by_id(integration_session['website_id'])
          @integration = @website.integrations.build(integration_session)
          @integration.assign_configuration(auth_hash)
          @integration.save!
          redirect_to installations_path(main_tab: 'integrations'), notice: 'Integration created'
        end
      rescue
        redirect_to installations_path(main_tab: 'integrations'), error: 'Error creating integration'
      ensure
        session['integration'] = nil
      end
    else
      after_login_redirect
    end
  end

  def failure
    if integration_session
      redirect_to installations_path(main_tab: 'integrations'), error: 'Error creating integration'
    else
      after_login_redirect
    end
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

  def integration_params
    @params ||= params.require(:integration).permit(:integration_type, :name, :provider)
  end
end
