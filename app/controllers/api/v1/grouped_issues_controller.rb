class Api::V1::GroupedIssuesController < Api::V1::ApiController
  skip_before_action :authenticate_member!, except: [:index]

  def index
    @page = params[:page] || 1
    @groups = current_site.groups.page @page
    @pages = @groups.total_pages
  end

  def show
    @grouped_issue = current_site.grouped_issues.where('issues.id = ?', params[:id]).first
  end
end
