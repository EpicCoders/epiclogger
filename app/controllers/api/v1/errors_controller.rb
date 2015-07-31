class Api::V1::ErrorsController < Api::V1::ApiController
  skip_before_action :authenticate_member!, except: [:index, :show, :update, :notify_subscribers]

  def index
    @errors = current_site.issues
  end

  def create
    @subscriber = Subscriber.where("email = ? and website_id = ?", params['email'], @current_site.id)
    @error = Issue.where("description = ?", params['message'])
    if @subscriber.blank?
      @subscriber = Subscriber.create( email: params['email'], name: params['email'], created_at: Time.now, updated_at: Time.now, website_id: @current_site.id)
    end

    if @error.blank?
      @error = Issue.create(description: params['message'], created_at: Time.now, updated_at: Time.now, status: 1, website_id: @current_site.id)
      SubscriberIssue.create(subscriber_id: @subscriber.id, issue_id: @error.id,created_at: Time.now, updated_at: Time.now)
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
