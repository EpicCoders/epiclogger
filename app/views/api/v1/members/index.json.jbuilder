json.members @members do |member|
  json.(member[0], :id, :name, :email)
  json.role member[1]
end