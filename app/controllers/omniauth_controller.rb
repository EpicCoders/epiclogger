class OmniauthController < ApplicationController
  layout "landing"
  skip_before_action :authenticate!

  def create
    user = User.new(user_params)
    user.save

    # authenticate!(:password)
    # after_login_redirect
  end

  private
  def user_params
    binding.pry
    params.require(:user).permit(:provider, :uid, :name, :email)
  end
end
