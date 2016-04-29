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
    resolved_errors = errors.where('resolved_at IS NOT NULL').order('last_seen DESC')
    unresolved_errors = errors.where(resolved_at: nil).order('last_seen DESC')
    @error_count = {total: errors.size, resolved: resolved_errors.size, unresolved: unresolved_errors.size}
    if to_boolean(resolved)
      @selected_errors = resolved_errors.page(@page).per(5)
    else
      @selected_errors = unresolved_errors.page(@page).per(5)
    end

    @issues = @error.issues.page(page_issue).per(1)
    @issue = @issues.first
    gon.chart_data = @error.chart_data
  end

  def update
    @error.update_attributes(status: error_params[:status], resolved_at: Time.now.utc)
  end

  def notify_subscribers
    @message = params[:message]
    @error.subscribers.each do |subscriber|
      UserMailer.notify_subscriber(@error, subscriber, @message).deliver_later
    end
  end

  def resolve
    #has values when we resolve issues through the error sidebar
    if params[:error_ids]
      ids = params[:error_ids]
      resolved = to_boolean(params[:resolved]) if params[:resolved]
      resolve_issues(ids, resolved)
    elsif params[:individual_resolve]
      ids = [@error.id]
      resolved = !@error.resolved_at.nil?
      resolve_issues(ids, resolved)
    else
      raise 'Could not find error!'
    end
  end

  private

  def resolve_issues (ids, resolved = true)
    errors_per_page = params[:per_page] || 5
    page = params[:page]
    errors = current_website.grouped_issues.order('last_seen DESC')
    if resolved
      GroupedIssue.where(id: ids).update_all(resolved_at: nil)
      resolved = errors.where('resolved_at IS NOT NULL')
      @sidebar = resolved.page(page).per(ids.size).offset(errors_per_page)
      @pagination = resolved.page(page).per(errors_per_page).offset(ids.size)
    else
      GroupedIssue.where(id: ids).update_all(resolved_at: DateTime.now)
      unresolved = errors.where(resolved_at: nil).page(page)
      @sidebar = unresolved.page(page).per(ids.size).offset(errors_per_page)
      @pagination = unresolved.page(page).per(errors_per_page).offset(ids.size)
    end
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
