class Api::V1::ErrorsController < Api::V1::ApiController
  require 'digest/md5'
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
    @error.subscribers.each do |member|
      UserMailer.notify_subscriber(@error, member, @message).deliver_now
    end
  end

  def add_error
    subscriber = current_site.subscribers.create_with(name: "Name for subscriber").find_or_create_by!(email: error_params["user"]["email"], website_id: current_site.id)

    @group = GroupedIssue.create_with(
      issue_logger: error_params["logger"],
      view: error_params["request"]["url"],
      status: 3,platform: error_params["platform"],
      message: error_params["message"]
    ).find_or_create_by(data: Digest::MD5.hexdigest(error_params["request"]["headers"]["User-Agent"]), website_id: current_site.id)

    @error = Issue.create_with(
      description: error_params["request"]["headers"]["User-Agent"],
      page_title: error_params["extra"]["title"],
      platform: error_params["platform"],
      group_id: @group.id
      # error_params["stacktrace"]["frames"].to_s.gsub(/=>|\./, ":")
    ).find_or_create_by(data: error_params["stacktrace"]["frames"].to_s.gsub('=>', ':'), subscriber_id: subscriber.id)

    message = Message.create(content: error_params["message"], issue_id: @error.id)
  end


  private
    def error_params
      if params[:sentry_data].is_a?(String)
        error_params ||= JSON.parse(params[:sentry_data])
      else
        error_params ||= params.require(:error).permit(:description, :message, :name, :status, :logger, :platform, :request => [:url, :headers => ["User-Agent"]], :user => [:email, :name], :extra => [:page_title])
      end
    end
end
