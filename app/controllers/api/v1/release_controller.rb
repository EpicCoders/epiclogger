class Api::V1::ReleaseController < Api::V1::ApiController
  def create
    @website = Website.find(params[:id])
    @last_release = @website.releases.last
    unless @last_release.version == params[:head_long]
      @current_release = Release.find_or_create_by(version: params[:head_long]) do |release|
        release.data = params
        release.website_id = params[:id]
      end
      @last_release.grouped_issues.update_all(:status => 2, :release_id => @current_release )
    end
  end
end
