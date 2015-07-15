json.subscribers @subscribers do |subscriber|
  json.(subscriber, :id, :name, :email, :created_at, :updated_at, :website_id)
end