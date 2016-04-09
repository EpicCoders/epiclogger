Rails.application.config.middleware.use Warden::Manager do |manager|
  manager.default_strategies :password
  manager.intercept_401 = false
  manager.failure_app = ->(env){ SessionsController.action(:unauthorized).call(env) }
end

Warden::Manager.serialize_into_session do |user|
  user.id
end

Warden::Manager.serialize_from_session do |id|
  User.find(id)
end

Warden::Strategies.add(:password) do
  def user_params
    params[:user]
  end

  def valid?
    return false if request.get?
    return false if user_params.nil?
    user_params[:email] && user_params[:password]
  end

  def authenticate!
    user = User.find_by_email(user_params[:email])
    if user && user.authenticate(user_params[:password])
      success! user
    else
      session.delete('session')
      fail "Invalid email or password"
    end
  end
end
