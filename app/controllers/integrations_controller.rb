class IntegrationsController < ApplicationController
  load_and_authorize_resource

  def update
    if params[:application]
      @integration.configuration["selected_application"] = @integration.configuration["selected_application"] = @integration.get_applications.find{|app| app[:title] == params[:application]}[:title]
      @integration.save
      redirect_to installations_path(main_tab: 'integrations', integration_tab: @integration.provider), notice: 'Application added!'
    else
      redirect_to installations_path(main_tab: 'integrations')
    end
  end

  def create_task
    task = @integration.create_task(params[:error_id])
    redirect_to error_path(params[:error_id], task: task)
  end
end