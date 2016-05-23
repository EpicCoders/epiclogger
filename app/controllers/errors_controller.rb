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

    resolved = params[:resolved] || 'true'
    errors = current_website.grouped_issues.order('last_seen DESC')
    resolved_errors = errors.with_status(:resolved).order('last_seen DESC')
    unresolved_errors = errors.with_status(:unresolved).order('last_seen DESC')
    @error_count = {total: errors.size, resolved: resolved_errors.size, unresolved: unresolved_errors.size}
    if to_boolean(resolved)
      @selected_errors = resolved_errors.page(@page).per(5)
    else
      @selected_errors = unresolved_errors.page(@page).per(5)
    end

    @issues = @error.issues.page(page_issue).per(1)
    @issue = @issues.first
    gon.chart_data = @error.issues.group_by_day(:created_at, range: Date.today.beginning_of_day - 1.months..Date.today.end_of_day).count.map{ |k, v| { date: k, value: v } }
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
    #has values when we resolve issues through the error sidebar
    errors_per_page = params[:per_page] || 5
    page = params[:page]
    if params[:error_ids]
      ids = params[:error_ids]
      resolved = to_boolean(params[:resolved]) if params[:resolved]
      resolve_issues(ids, resolved, errors_per_page, page, @error)
    elsif params[:individual_resolve]
      ids = [@error.id]
      resolved = !@error.resolved_at.nil?
      resolve_issues(ids, resolved, errors_per_page, page, @error)
    else
      raise 'Could not find error!'
    end
  end

  private

  def resolve_issues (ids, resolved = true, errors_per_page, page, current_error)
    errors = current_error.website.grouped_issues.order('last_seen DESC')
    if resolved
      GroupedIssue.where(id: ids).update_all(resolved_at: nil, status: GroupedIssue::UNRESOLVED) # 3 = unresolved
      errors = errors.with_status(:resolved)
    else
      GroupedIssue.where(id: ids).update_all(resolved_at: Time.now.utc, status: GroupedIssue::RESOLVED) # 2 = resolved
      errors = errors.with_status(:unresolved)
    end
    @sidebar = errors.page(page).per(ids.size).offset(errors_per_page)
    @pagination = errors.page(page).per(errors_per_page).offset(ids.size)
  end

  def to_boolean(str)
    return true if str=="true"
    return false if str=="false"
    return nil
  end

  def error_params
    @error_params ||= params.require(:error).permit(:description, :message, :name, :status, :logger, :platform)
  end
end
