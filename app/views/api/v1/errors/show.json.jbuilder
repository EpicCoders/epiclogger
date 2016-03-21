json.(@error, :id, :message, :culprit, :times_seen, :first_seen, :last_seen, :score, :status, :level, :issue_logger, :resolved_at)
json.subscribers @error.website.subscribers do |subscriber|
  json.(subscriber, :id, :email)
  hash = Digest::MD5.hexdigest(subscriber.email)
  json.avatar_url "http://www.gravatar.com/avatar/#{hash}"
end
json.subscribers_count @error.website.subscribers.count
json.issues @error.issues do |issue|
  json.(issue, :id, :platform, :event_id, :data, :message, :datetime, :time_spent)
  json.data issue.error.data
end
