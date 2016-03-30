def auth_user(user)
  sign_in user
  request.headers.merge!(user.create_new_auth_token)
end