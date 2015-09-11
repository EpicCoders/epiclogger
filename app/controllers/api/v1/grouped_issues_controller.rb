class Api::V1::GroupedIssuesController < Api::V1::ApiController
  skip_before_action :authenticate_member!, except: [:index]

  def index
    @page = params[:page] || 1
    @groups = current_site.groups.page @page
    @pages = @groups.total_pages
  end

  def show
    @page = params[:page] || 1
    @group = GroupedIssue.find(params[:id]).issues.page @page
    @pages = @group.total_pages
  end
end
