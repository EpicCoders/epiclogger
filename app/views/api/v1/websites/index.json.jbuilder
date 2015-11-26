json.websites @websites do |website|
  json.(website, :id, :title, :domain, :app_secret, :app_key)
  json.errors website.grouped_issues.count
  json.subscribers website.subscribers.count
  json.members website.members.count
end