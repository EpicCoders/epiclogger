json.groups @groups do |group|
  json.(group, :id, :issue_logger, :created_at, :website_id, :level, :status, :message)
  json.last_occurrence group.updated_at
end

json.page @page.to_i
json.pages @pages