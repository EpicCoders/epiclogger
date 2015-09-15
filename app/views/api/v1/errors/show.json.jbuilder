json.(@error, :id, :description, :page_title, :data, :created_at, :updated_at, :platform, :time_spent)
json.subscribers_count @error.subscribers.count
json.status @status


