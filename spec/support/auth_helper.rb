def auth_member(member)
  sign_in member
  request.headers.merge!(member.create_new_auth_token)
end