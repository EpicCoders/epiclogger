json.(@website, :id, :app_secret, :app_key, :domain, :title, :platform, :new_event, :frequent_event, :daily, :realtime)
json.owners @website.members.where('website_members.role' => WebsiteMember.role.find_value(:owner).value)
