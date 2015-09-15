class Api::V1::ErrorsController < Api::V1::ApiController
  skip_before_action :authenticate_member!, except: [:index, :show, :update, :notify_subscribers]

  def index
    @page = params[:page] || 1
    @errors = current_site.grouped_issues.page @page
    @pages = @errors.total_pages
  end

  def show
    @grouped_issue = GroupedIssue.find(params[:id])
  end

   def update
    @error = GroupedIssue.find(params[:id])
    @error.update_attributes(status: error_params[:status], resolved_at: Time.now)
  end

  def notify_subscribers
    @error = GroupedIssue.find(params[:id])
    @message = params[:message]
    @error.issues.each do |issue|
      issue.subscribers.each do |member|
        UserMailer.notify_subscriber(@error, member, @message).deliver_now
      end
    end
  end

  def add_error
    subscriber = current_site.subscribers.create_with(name: error_params["user"]["name"]).find_or_create_by!(email: error_params["user"]["email"])
    @error = current_site.issues.create_with(description: error_params["message"]).find_or_create_by(page_title: error_params["extra"]["page_title"])
    # @error.increment!(:occurrences)1

    SubscriberIssue.create_with(issue_id: @error.id).find_or_create_by(subscriber_id: subscriber.id)
    message = Message.create(content: error_params["message"], issue_id: @error.id)
  end


  private
    def error_params
      if params[:sentry_data].is_a?(String)
        error_params ||= JSON.parse(params[:sentry_data])
      else
        error_params ||= params.require(:error).permit(:description, :message, :name, :status, :user => [:email, :name], :extra => [:page_title])
      end
    end
end
