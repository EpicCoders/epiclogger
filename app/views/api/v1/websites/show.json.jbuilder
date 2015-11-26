json.(@website, :id, :app_secret, :app_key, :domain, :title)
json.errors @website.grouped_issues.count
json.subscribers @website.subscribers.count
json.members @website.members.count
