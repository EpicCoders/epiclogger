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
    @error.update_attributes(error_params)
  end

  def notify_subscribers
    @error = Issue.find(params[:id])
    @message = params[:message]
    Website.find(@error.website_id).subscribers.each do |member|
      UserMailer.issue_solved(@error, member, @message).deliver_now
    end 
  end


  private
    def error_params
      params.require(:error).permit(:status)
    end
end
