class OmniauthController < ApplicationController
  layout "landing"
  skip_before_action :authenticate!

  def create
    auth = request.env["omniauth.auth"]
    user = User.find_by_provider_and_uid(auth["provider"], auth["uid"]) || User.create_with_omniauth(auth)

    authenticate!(auth["provider"].to_sym) if user
    after_login_redirect
  end
end
