json.websites @websites do |website|
  json.(website, :id, :title, :domain, :app_id, :app_key)
end