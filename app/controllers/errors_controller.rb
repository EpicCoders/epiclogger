class ErrorsController < ApplicationController
  load_and_authorize_resource class: GroupedIssue

  def index
    @filter = params[:filter] || "recent"
    errors_per_page = params[:error_count].to_i || 10
    current_error = params[:current_issue]
    @page = params[:page] || 1 if current_error
    case @filter
    when "recent"
      @errors = current_website.grouped_issues.order('last_seen DESC').page(@page).per(errors_per_page)
    when "unresolved", "resolved"
      @errors = current_website.grouped_issues.where(status: GroupedIssue.status.find_value(@filter.to_sym).value).page(@page).per(errors_per_page)
    when "most_encountered"
      @errors = current_website.grouped_issues.joins(:issues).group("grouped_issues.id").order("count(grouped_issues.id) DESC").page(@page).per(errors_per_page)
    end
    @errors = current_website.grouped_issues.where('lower(message) ILIKE ? OR lower(culprit) ILIKE ?', "%#{params[:search].downcase}%", "%#{params[:search].downcase}%").page(@page).per(errors_per_page) if params[:search]
    @pages = @errors.total_pages
  end

  def show
    page_issue = params[:page_issue] || 1
    page = params[:page] || 1
    errors_per_page = 5
    errors = current_website.grouped_issues.order('last_seen DESC')
    if !params[:tab].present? && params[:page].nil?
      errors = @error.resolved? ? errors.with_status(:resolved) : errors.with_status(:unresolved)
      position = errors.where("last_seen >= ?", @error.last_seen).count
      page = (position.to_f/errors_per_page).ceil
    else
      errors = params[:tab] == 'resolved' ? errors.with_status(:resolved) : errors.with_status(:unresolved)
    end
    @selected_errors = errors.page(page).per(errors_per_page)
    @issues = @error.issues.page(page_issue).per(1)
    @issue = @issues.first
  end

  def update
    @error.update_attributes(status: error_params[:status], resolved_at: Time.now.utc)
    render nothing: true
  end

  def notify_subscribers
    @message = params[:message]
    @error.website.users.each do |member|
      UserMailer.notify_subscriber(@error, member, @message).deliver_later
    end
  end

  def resolve
    GroupedIssue.where(id: params[:error_ids].flatten).update_all(resolved_at: Time.now.utc, status: GroupedIssue::RESOLVED)
    redirect_to error_path(@error)
  end

  def unresolve
    GroupedIssue.where(id: params[:error_ids].flatten).update_all(resolved_at: nil, status: GroupedIssue::UNRESOLVED)
    redirect_to error_path(@error)
  end

  private

  def error_params
    @error_params ||= params.require(:error).permit(:description, :message, :name, :status, :logger, :platform)
  end
end
