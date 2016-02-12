module ControllerHelpers
  def login_with(member = double('member'))
    if member.nil?
      allow(request.env['warden']).to receive(:authenticate_member!).and_throw(:warden, {:scope => :member})
      allow(controller).to receive(:current_member).and_return(nil)
    else
      allow(request.env['warden']).to receive(:authenticate_member!).and_return(member)
      allow(controller).to receive(:current_member).and_return(member)
      tokens = member.create_new_auth_token
      page.driver.set_cookie("access-token", tokens["access-token"])
      page.driver.set_cookie("client", tokens["client"])
      page.driver.set_cookie("uid", tokens["uid"])
      page.driver.set_cookie("expiry", tokens["expiry"])
      page.driver.set_cookie("token-type", tokens["token-type"])
    end
  end
end