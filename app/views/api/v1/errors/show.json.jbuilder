json.(@grouped_issue, :id, :message, :view, :times_seen, :first_seen, :last_seen, :data, :score, :status, :level, :issue_logger, :resolved_at)
json.issues @grouped_issue.issues do |issue|
  json.(issue, :id, :platform, :page_title)
  json.data JSON.parse(issue.data)
  json.description JSON.parse(issue.description)
  json.subscriber do
    json.(issue.subscriber, :id, :email)
    hash = Digest::MD5.hexdigest(issue.subscriber.email)
    json.avatar_url "http://www.gravatar.com/avatar/#{hash}"
  end
  json.subscribers_count @grouped_issue.subscribers.count
end
