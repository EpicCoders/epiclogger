json.groups @errors do |group|
  json.(group, :id, :issue_logger, :created_at, :website_id, :level, :status, :message, :last_seen, :platform)
  json.view JSON.parse(group.view)
end
json.page @page.to_i
json.pages @pages