class AuthController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:success]
  skip_before_action :authenticate!, only: [:success]

  def create
    unless Integrations.supports?(integration_params[:provider])
      redirect_to settings_path(main_tab: 'integrations'), notice: 'Invalid Integration'
      return
    end

    @integration = Integration.new(integration_params)
    if @integration.valid?
      @integration.website = current_website
      session['integration'] = integration_params
      redirect_to "/auth/#{@integration.provider}"
    else
      redirect_to settings_path(main_tab: 'integrations'), notice: 'Integration parameters are invalid!'
    end
  end

  def success
    unless authenticated?
      user = User.find_by_provider_and_uid(provider, auth_hash['uid']) || User.create_with_omniauth(auth_hash)
      if user
        authenticate!(provider.to_sym)
        set_website(current_user.websites.first) unless current_user.websites.empty?
      end
    end
    if integration_session
      # create integration
      begin
        Integration.transaction do
          @integration = current_website.integrations.build(integration_session)
          @integration.assign_configuration(auth_hash)
          @integration.save!
          redirect_to settings_path(main_tab: 'integrations', integration_tab: provider ), notice: 'Integration created'
        end
      rescue
        redirect_to settings_path(main_tab: 'integrations'), flash: { error: 'Error creating integration' }
      ensure
        session['integration'] = nil
      end
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
