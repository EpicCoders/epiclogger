class Api::V1::ErrorsController < Api::V1::ApiController
  skip_before_action :authenticate_member!

  def index
    @errors = current_site.issues
  end

  def create
    # binding.pry
  end

  def show
    @error = current_site.issues.where('issues.id = ?', params[:id]).first
  end
end
