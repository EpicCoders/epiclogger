json.members @members do |website_member|
  json.(website_member, :id, :role)
  json.name website_member.member.name
  json.email website_member.member.email
end