json.(@grouped_issue, :id, :message, :view, :times_seen, :first_seen, :last_seen, :data, :score, :status, :level, :issue_logger, :resolved_at)
json.issues @grouped_issue.issues do |issue|
  json.(issue, :id, :platform, :data)
  json.subscriber do
    json.(issue.subscriber, :id, :email)
    hash = Digest::MD5.hexdigest(issue.subscriber.email)
    json.avatar_url "http://www.gravatar.com/avatar/#{hash}"
  end
end
