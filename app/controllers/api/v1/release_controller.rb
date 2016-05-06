class Api::V1::ReleaseController < Api::V1::ApiController
  def create
  	Release.create!(release_params)
  end

  def release_params
    params.require(:release).permit(:id, :website_id, :data, :version)
  end
end
