class Api::V1::ErrorsController < Api::V1::ApiController
  load_and_authorize_resource class: GroupedIssue
  require 'digest/md5'
  require 'net/http'
  require 'uri'
  skip_before_action :authenticate_member!, except: [:index, :show, :update, :notify_subscribers]

  def index
    errors_per_page = params[:error_count].to_i || 10
    current_error = params[:current_issue]
    if current_error
      @page = current_issue_page(errors_per_page,current_error)
    else
      @page = params[:page] || 1
    end
    @errors = current_site.grouped_issues.order('last_seen DESC').page(@page).per(errors_per_page)
    @pages = @errors.total_pages
  end

  def show
    @error
  end

  def update
    @error.update_attributes(status: error_params[:status], resolved_at: Time.now)
  end

  def notify_subscribers
    @message = params[:message]
    @error.website.members.each do |member|
      UserMailer.notify_subscriber(@error, member, @message).deliver_now
    end
  end

  private

  def error_params
    @error_params ||= params.require(:error).permit(:description, :message, :name, :status, :logger, :platform, :stacktrace => [:frames => ["filename"]] ,:request => [:url, :headers => ["User-Agent"]], :user => [:email, :name], :extra => [:title])
  end
end
