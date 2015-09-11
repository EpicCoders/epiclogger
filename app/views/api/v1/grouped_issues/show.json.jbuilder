json.group @group do |error|
  json.(error, :id, :description, :created_at, :website_id, :group_id, :page_title, :platform, :data, :time_spent)
  json.last_occurrence error.updated_at
  json.users_count error.subscribers.count
end

json.page @page.to_i
json.pages @pages