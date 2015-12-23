json.members @members do |website_member|
  json.(website_member, :id, :role, :website_id)
  json.name website_member.member.name
  json.email website_member.member.email
end