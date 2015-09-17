json.(@grouped_issue, :id, :message, :view, :times_seen, :first_seen, :last_seen, :data, :score, :status, :level, :issue_logger, :resolved_at)
json.issues @grouped_issue.issues do |issue|
  json.(issue, :id, :platform, :data)
  json.subscribers_count issue.subscribers.count
end
json.avatars @avatars