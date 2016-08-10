class IntegrationsController < ApplicationController
  load_and_authorize_resource

  def update
    if integration_params[:app_name] && params[:app_list]
      integration_params[:app_owner] = params[:app_list].select { |k,v| v.include?(integration_params[:app_name]) }.keys[0]
    end
    if @integration.update_attributes(integration_params)
      redirect_to settings_path(main_tab: 'integrations', integration_tab: @integration.provider), notice: 'Integration updated!'
    end
  end

  def destroy
    if @integration.destroy
      redirect_to settings_path(main_tab: 'integrations', integration_tab: @integration.provider), notice: 'Integration deleted!'
    end
  end

  def create_task
    begin
      task = @integration.driver.create_task(params[:title])
      redirect_to error_path(params[:error_id], task: task)
    rescue => exception
      Raven.capture_exception(exception)
      redirect_to error_path(params[:error_id], task: task), flash: { error: "Operation failed!" }
    end
  end

  def integration_params
    @integration_params ||= params.require(:integration).permit(:app_name, :app_owner)
  end
end
