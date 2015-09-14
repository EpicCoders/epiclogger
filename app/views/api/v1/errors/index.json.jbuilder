json.groups @groups do |group|
  json.(group, :id, :issue_logger, :created_at, :website_id, :level, :status, :message)
  json.last_occurrence group.updated_at
  json.issues group.issues do |issue|
    json.(issue, :id, :description, :created_at, :website_id, :group_id, :page_title, :platform, :data, :time_spent)
    json.last_occurrence issue.updated_at
    json.users_count issue.subscribers.count
  end
end

json.page @page.to_i
json.pages @pages