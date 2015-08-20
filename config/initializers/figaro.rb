if defined?(Figaro)
  Figaro.require_keys("APP_DOMAIN", "MAILER_HOST", "GITHUB_SECRET", "GITHUB_KEY")
end