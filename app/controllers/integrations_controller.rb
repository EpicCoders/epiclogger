class IntegrationsController < ApplicationController
  load_and_authorize_resource

  def update
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
    rescue
      redirect_to error_path(params[:error_id], task: task), flash: { error: "Operation failed!" }
    end
  end

  def integration_params
    @integration_params ||= params.require(:integration).permit(:application)
  end
end