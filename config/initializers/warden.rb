Rails.application.config.middleware.use Warden::Manager do |manager|
  manager.default_strategies :password
  manager.intercept_401 = false
  manager.failure_app = lambda{ |env| SessionsController.action(:new).call(env) }
end

Warden::Manager.serialize_into_session do |member|
  member.id
end

Warden::Manager.serialize_from_session do |id|
  Member.find(id)
end

Warden::Strategies.add(:password) do
  def session_params
    if params['session'].nil?
      return nil if session['session'].nil?
      return nil if session['session'].try(:[],'email').nil? || session['session'].try(:[],'password').nil?
      return {email: session['session']['email'], password: session['session']['password']}
    else
      return nil if params['session'].nil?
      return nil if params['session'].try(:[],'email').nil? || params['session'].try(:[],'password').nil?
      return {email: params['session']['email'], password: params['session']['password']}
    end
  end

  def valid?
    return false if request.get?
    return false if session_params.nil?
    session_params[:email] && session_params[:password]
  end

  def authenticate!
    member = Member.find_by_email(session_params[:email])
    if member && member.authenticate(session_params[:password])
      session.delete('session')
      success! member
    else
      session.delete('session')
      fail "Invalid email or password"
    end
  end
end
