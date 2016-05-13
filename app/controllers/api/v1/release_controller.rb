class Api::V1::ReleaseController < Api::V1::ApiController
  def create
    @website = Website.find(params[:id])
    @website.check_release(params[:head_long])
  end
end
