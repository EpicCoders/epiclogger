json.(@grouped_issue, :id, :message, :view, :times_seen, :first_seen, :last_seen, :data, :score, :status, :level, :issue_logger)
json.issues @grouped_issue.issues do |issue|
  json.(issue, :id, :platform, :data)
  json.subscribers issue.subscribers.count
end