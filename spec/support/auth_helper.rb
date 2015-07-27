module AuthHelper
  def auth_request(member)
    sign_in member
    request.headers.merge!(member.create_new_auth_token)
  end
end