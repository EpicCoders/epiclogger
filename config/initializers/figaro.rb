if defined?(Figaro)
  if Rails.env.review?
    Figaro.require_keys('GITHUB_SECRET', 'GITHUB_KEY')
  else
    Figaro.require_keys('APP_DOMAIN', 'MAILER_HOST', 'EPICLOGGER_DSN', 'GITHUB_SECRET', 'GITHUB_KEY')
  end
end
