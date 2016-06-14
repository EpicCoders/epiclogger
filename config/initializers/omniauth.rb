Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, Integrations.config[:github][:app_key], Integrations.config[:github][:app_secret], scope: 'email,profile,repo'
  provider :intercom, Integrations.config[:intercom][:app_key], Integrations.config[:intercom][:app_secret]
end
