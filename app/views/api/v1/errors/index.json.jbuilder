json.errors @errors do |error|
  json.(error, :id, :description, :created_at, :website_id, :page_title)
  json.last_occurrence error.updated_at
  json.users_count error.subscribers.count
end

json.page @page.to_i
json.pages @pages