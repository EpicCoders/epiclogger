Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, Integrations.config[:github][:client_id], Integrations.config[:github][:client_secret], scope: 'email,profile,repo'
  provider :intercom, Integrations.config[:intercom][:client_id], Integrations.config[:intercom][:client_secret]
end
