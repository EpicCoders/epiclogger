class Api::V1::GroupedIssuesController < Api::V1::ApiController
  skip_before_action :authenticate_member!, except: [:index]

  def show
    @error = current_site.issues.where('issues.id = ?', params[:id]).first
  end
end
