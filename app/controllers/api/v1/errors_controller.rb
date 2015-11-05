class Api::V1::ErrorsController < Api::V1::ApiController
  load_and_authorize_resource class: GroupedIssue
  require 'digest/md5'
  require 'net/http'
  require 'uri'
  skip_before_action :authenticate_member!, except: [:index, :show, :update, :notify_subscribers]

  def index
    @page = params[:page] || 1
    errors_per_page = params[:error_count] || 10
    @errors = current_site.grouped_issues.page(@page).per(errors_per_page)
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

  def add_error
    subscriber = current_site.subscribers.create_with(name: 'Name for subscriber').find_or_create_by!(email: error_params["user"]["email"], website_id: current_site.id)

    if error_params['stacktrace'].blank?
      checksum = Digest::MD5.hexdigest(error_params['platform'] + error_params['culprit'] + error_params['message'])
    else
      checksum = Digest::MD5.hexdigest(error_params['stacktrace'].to_s)
    end
    @group = GroupedIssue.create_with(
      issue_logger: error_params['logger'],
      view: error_params['request'].to_s.gsub('=>', ':'),
      status: 3, platform: error_params['platform'],
      message: error_params['message']
    ).find_or_create_by(data: checksum, website_id: current_site.id)

    source_code = open_url_content(error_params['stacktrace'])

    @error = Issue.create_with(
      description: error_params['stacktrace']['frames'].to_s.gsub('=>', ':'),
      page_title: error_params['extra']['title'],
      platform: error_params['platform'],
      group_id: @group.id
    ).find_or_create_by(data: source_code, subscriber_id: subscriber.id)

    Message.create(content: error_params['message'], issue_id: @error.id)
  end

  def open_url_content(stacktrace)
    nr = 0
    content = []
    stacktrace['frames'].each do |frame|
      nr += 1
      content.push({'content_#{nr}' => Net::HTTP.get(URI.parse(frame['filename']))})
      # content += "," if nr > 0
    end
    content.to_s.gsub('=>', ':')
  end

  private

  def error_params
    if params[:sentry_data].is_a?(String)
      error_params ||= JSON.parse(params[:sentry_data])
    else
      error_params ||= params.require(:error).permit(:description, :message, :name, :status, :logger, :platform, :stacktrace => [:frames => ["filename"]] ,:request => [:url, :headers => ["User-Agent"]], :user => [:email, :name], :extra => [:title])
    end
  end
end
