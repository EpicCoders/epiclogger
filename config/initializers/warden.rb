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
    if user && user.authenticate(user_params[:password]) && user.confirmation_token.nil?
      success! user
    else
      session.delete('session')
      fail "Confirm email or retype your credentials"
    end
  end
end

Warden::Strategies.add(:github) do
  def valid?
    return false if auth_hash.nil?
    (auth_hash.provider == 'github') ? true : false
    (auth_hash.uid.blank?) ? false : true
  end

  def auth_hash
    request.env['omniauth.auth']
  end

  def authenticate!
    if usr = User.find_by(:uid => auth_hash.uid)
      success!(usr)
    elsif usr = User.find_by(:email => auth_hash.info.email)
      network = Network.new({name:'github', uid:auth_hash.uid, oauth_token:auth_hash.credentials.token})
      usr.networks.push network
      usr.save!
      success!(usr)
    end
  end
end
