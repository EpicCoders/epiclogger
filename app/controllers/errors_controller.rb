class ErrorsController < ApplicationController
  load_and_authorize_resource class: GroupedIssue

  def index
    @filter = params[:filter] || "recent"
    errors_per_page = params[:error_count].to_i || 25
    @page = params[:page] || 1
    case @filter
    when "recent"
      @errors = current_website.grouped_issues.order('last_seen DESC').page(@page).per(errors_per_page)
    when "unresolved", "resolved"
      @errors = current_website.grouped_issues.where(status: GroupedIssue.status.find_value(@filter.to_sym).value).page(@page).per(errors_per_page)
    when "most_encountered"
      @errors = current_website.grouped_issues.joins(:issues).group("grouped_issues.id").order("count(grouped_issues.id) DESC").page(@page).per(errors_per_page)
    end
    @errors = matching_elements.page(@page).per(errors_per_page) if params[:search]
    @pages = @errors.total_pages
  end

  def show
    page_issue = params[:page_issue] || 1
    page = params[:page] || 1
    errors_per_page = 25
    errors = current_website.grouped_issues.order('last_seen DESC')
    resolve if params[:commit] == 'Resolve'
    unresolve if params[:commit] == 'Unresolve'
    if params[:tab] == 'default' && params[:page].nil?
      errors = @error.resolved? ? errors.with_status(:resolved) : errors.with_status(:unresolved)
      position = errors.where("last_seen >= ?", @error.last_seen).count
      page = (position.to_f/errors_per_page).ceil
      errors = errors.with_status(params[:status].to_sym) unless params[:status].blank?
    elsif params[:commit] == 'search-button' && !params[:search].blank?
      errors = matching_elements
    elsif !params[:datepicker].blank?
      range = params[:datepicker].split(/\ - /).map {|t| Time.parse(t)}
      errors = GroupedIssue.where('first_seen > ?', range.first).order('last_seen DESC') if range.first == range.last
      errors = GroupedIssue.where('first_seen >= ? AND last_seen <= ?', range.first, range.last).order('last_seen DESC') if range.first != range.last
    end
    errors = errors.where("environment = ?", params[:env]) unless params[:env].blank?
    errors = errors.with_status(:resolved) if params[:tab] == 'resolved' || params[:status] == 'resolved'
    errors = errors.with_status(:unresolved) if params[:tab] == 'unresolved'  || params[:status] == 'unresolved'
    flash[:notice] = "No matches" if errors.blank?
    @selected_errors = errors.page(page).per(errors_per_page)
    @issues = @error.issues.page(page_issue).per(1)
    @chart_data = @error.issues.group_by_day(:created_at, range: Date.today.beginning_of_day - 1.months..Date.today.end_of_day).count
    @issue = @issues.first
  end

  def update
    @error.update_attributes(status: error_params[:status], resolved_at: Time.now.utc)
    head :ok
  end

  def notify_subscribers
    unless params[:message].blank?
      return redirect_to error_path(@error), flash: { error: 'Message too short!' } if params[:message].length < 10
      if params[:intercom]
        begin
          current_website.intercom_integration.driver.send_message(@error.subscribers.pluck(:email), params[:message])
          redirect_to error_path(@error), flash: { success: 'Message successfully sent!' }
        rescue => e
          Raven.capture_exception(e)
          redirect_to error_path(@error), flash: { error: 'Operation failed!' }
        end
      else
        @message = Message.create( content: params[:message], issue_id: @error.issues.last.id )
        @error.subscribers.each do |subscriber|
          GroupedIssueMailer.notify_subscriber(@error, subscriber, current_user, @message).deliver_later
        end
        redirect_to error_path(@error), flash: { success: 'Message successfully sent!' }
      end
    end
  end

  def matching_elements
    current_website.grouped_issues.where('lower(message) ILIKE ? OR lower(culprit) ILIKE ? OR lower(platform) ILIKE ? OR lower(level) ILIKE ?', "%#{params[:search].downcase}%", "%#{params[:search].downcase}%", "%#{params[:search].downcase}%", "%#{params[:search].downcase}%")
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
