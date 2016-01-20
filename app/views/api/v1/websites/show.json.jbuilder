json.(@website, :id, :app_id, :app_key, :domain, :title, :new_event, :frequent_event, :daily, :realtime)
json.errors @website.grouped_issues.count
json.subscribers @website.subscribers.count
json.members @website.members.count
