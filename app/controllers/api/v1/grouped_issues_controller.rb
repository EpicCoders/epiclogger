class Api::V1::GroupedIssuesController < Api::V1::ApiController
  def show
    # TODO wtf is this?? for??
    @error = current_site.issues.where('issues.id = ?', params[:id]).first
  end
end
