json.websites @websites do |website|
  json.(website, :id, :title, :domain, :app_secret, :app_key)
end