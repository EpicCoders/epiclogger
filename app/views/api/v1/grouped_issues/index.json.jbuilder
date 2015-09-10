json.grouped_issues @grouped_issues do |grouped_issue|
  json.(grouped_issue, :id, :issue_logger, :created_at, :website_id, :level, :status, :message)
  json.last_occurrence grouped_issue.updated_at
end

json.page @page.to_i
json.pages @pages