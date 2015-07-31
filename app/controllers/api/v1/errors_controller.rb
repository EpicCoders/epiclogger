class Api::V1::ErrorsController < Api::V1::ApiController
  skip_before_action :authenticate_member!, except: [:index, :show, :update, :notify_subscribers]

  def index
    @errors = current_site.issues
  end

  def create
    binding.pry
    subscriber = current_site.subscribers.find_by(email: params[:email])
    error = current_site.issues.find_by(page_title: params[:page_title])
    if subscriber
      subscriber = current_site.subscribers.create( email: params['email'], name: params['email'], website_id: current_site.id)
    end

    if error
      error = current_site.issues.create(description: 'Issue description..', website_id: current_site.id)
      message = Message.create(content: params['message'], issue_id: error.id)
      SubscriberIssue.create(subscriber_id: subscriber.id, issue_id: error.id)
    end
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


  private
    def error_params
      params.require(:error).permit(:status)
    end
end
