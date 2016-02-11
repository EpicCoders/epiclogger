json.(@error, :id, :message, :culprit, :times_seen, :first_seen, :last_seen, :score, :status, :level, :issue_logger, :resolved_at)
json.issues @error.issues do |issue|
  json.(issue, :id, :platform)
  json.data issue.error.data
  json.subscriber do
    json.(issue.subscriber, :id, :email)
    hash = Digest::MD5.hexdigest(issue.subscriber.email)
    json.avatar_url "http://www.gravatar.com/avatar/#{hash}"
  end
  json.subscribers_count @error.subscribers.count
end
