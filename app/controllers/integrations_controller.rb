class IntegrationsController < ApplicationController
  load_and_authorize_resource

  def update
    if params[:application]
      @integration.application = Application.new(@integration.get_applications.find{|app| app[:title] == params[:application]})
      redirect_to installations_path(main_tab: 'integrations', integration_tab: @integration.provider), notice: 'Application added!'
    else
      redirect_to installations_path(main_tab: 'integrations')
    end
  end
end