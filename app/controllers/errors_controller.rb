class ErrorsController < ApplicationController
  load_and_authorize_resource class: GroupedIssue

  def index
    errors_per_page = params[:error_count].to_i || 10
    current_error = params[:current_issue]
    if current_error
    #   @page = current_issue_page(errors_per_page, current_error)
    # else
      @page = params[:page] || 1
    end
    @errors = current_website.grouped_issues.order('last_seen DESC').page(@page).per(errors_per_page)
    @pages = @errors.total_pages
  end

  def show
    @page = params[:page]
    page_issue = params[:page_issue] || 1
    @errors = current_website.grouped_issues.order('last_seen DESC').page(@page).per(5)
    @issues = @error.issues.page(page_issue).per(1)
    @issue = @issues.first
  end

  def update
    @error.update_attributes(status: error_params[:status], resolved_at: Time.now.utc)
  end

  def notify_subscribers
    @message = params[:message]
    @error.website.users.each do |member|
      UserMailer.notify_subscriber(@error, member, @message).deliver_later
    end
  end

  def resolve
    if !@error.resolved_at.nil?
      @error.update_attributes(resolved_at: nil)
    else
      @error.update_attributes(resolved_at: DateTime.now)
    end
  end

  private

  def error_params
    @error_params ||= params.require(:error).permit(:description, :message, :name, :status, :logger, :platform)
  end
end
