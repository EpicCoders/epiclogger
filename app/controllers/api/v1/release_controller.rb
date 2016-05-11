class Api::V1::ReleaseController < Api::V1::ApiController
  def create
    @website = Website.find(params[:id])
    unless @website.release.version == params[:head_long]
      @website.release.grouped_issues.update_all(:status => 2)
      @website.release.update_attributes(:version => params[:head_long], :data => params)
    end
  end
end
