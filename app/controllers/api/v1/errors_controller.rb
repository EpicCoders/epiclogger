class Api::V1::ErrorsController < Api::V1::ApiController
  skip_before_action :authenticate_member!, except: [:index, :show, :update, :notify_subscribers]

  def index
    @page = params[:page] || 1
    @errors = current_site.issues.page @page
    @pages = @errors.total_pages
  end

  def create
    # subscriber = current_site.subscribers.create_with(name: error_params[:name]).find_or_create_by!(email: error_params[:email])
    # @error = current_site.issues.create_with(description: 'etcdasdasadsad').find_or_create_by(page_title: error_params[:page_title])
  #   @error.increment!(:occurrences)

    # SubscriberIssue.create_with(issue_id: @error.id).find_or_create_by(subscriber_id: subscriber.id)
    # message = Message.create(content: error_params['message'], issue_id: @error.id)
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
    @error.subscribers.each do |member|
      UserMailer.notify_subscriber(@error, member, @message).deliver_now
    end
  end

  def add_error
    subscriber = current_site.subscribers.create_with(name: "test").find_or_create_by!(email: error_params["email"])
    @error = current_site.issues.create_with(description: 'dasdasdsa').find_or_create_by(page_title: error_params["page_title"])
    @error.increment!(:occurrences)

    SubscriberIssue.create_with(issue_id: @error.id).find_or_create_by(subscriber_id: subscriber.id)
    message = Message.create(content: error_params["message"], issue_id: @error.id)
  end


  private
    def error_params
      # params[:error] = JSON.parse(params[:error]) if params[:error].is_a?(String)
      # params.require(:error).permit(:status, :description, :page_title, :message, :name, :email)
      if params[:error].is_a?(String)
        error_params ||= JSON.parse(params[:error])
      else
        error_params ||= params.require(:error).permit(:status, :description, :page_title, :message, :name, :email)
      end
    end
end
