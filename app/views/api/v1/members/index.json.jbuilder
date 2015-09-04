json.members @members do |member|
  json.(member, :id, :name, :email)
  json.role WebsiteMember.role.find_value(member.role)
end