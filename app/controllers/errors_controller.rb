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
    @page = params[:page]
    page_issue = params[:page_issue] || 1

    errors = current_website.grouped_issues

    #get error-sidebar data
    if params[:unresolved].present?
      @selected_errors = errors.with_status(:unresolved).order('last_seen DESC').page(@page).per(5)
    else
      @selected_errors = errors.with_status(:resolved).order('last_seen DESC').page(@page).per(5)
    end

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
    resolve_issues(params[:error_ids], true, params[:per_page], params[:page], @error.id)
  end

  def unresolve
    resolve_issues(params[:error_ids], false, params[:per_page], params[:page], @error.id)
  end

  private

  def resolve_issues (ids, resolve, errors_per_page, page, current_error)
    errors_per_page ||= 5
    page ||= 1
    errors = GroupedIssue.find(current_error).website.grouped_issues.order('last_seen DESC')
    if resolve
      GroupedIssue.where(id: ids).update_all(resolved_at: Time.now.utc, status: GroupedIssue::RESOLVED)
      errors = errors.with_status(:unresolved)
    else
      GroupedIssue.where(id: ids).update_all(resolved_at: nil, status: GroupedIssue::UNRESOLVED)
      errors = errors.with_status(:resolved)
    end

    @sidebar = errors.page(page).per(ids.try(:size))
    @pagination = errors.page(page).per(errors_per_page)
  end

  def error_params
    @error_params ||= params.require(:error).permit(:description, :message, :name, :status, :logger, :platform)
  end
end
