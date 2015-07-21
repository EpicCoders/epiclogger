class Api::V1::ErrorsController < Api::V1::ApiController
  skip_before_action :authenticate_member!

  def index
    @errors = current_site.issues
  end

  def create
  end

  def show
    @error = current_site.issues.where('issues.id = ?', params[:id]).first
  end

   def update
    @error = Issue.find(params[:id])
    if @error.update_attributes(error_params)
      Website.find(@error.website_id).subscribers.each do |member|
        UserMailer.issue_solved(@error, member).deliver_now
      end
    end
  end

  private
    def error_params
      params.require(:error).permit(:status)
    end
end
