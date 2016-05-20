if defined?(Figaro)
  Figaro.require_keys("MAILER_HOST", "GITHUB_SECRET", "GITHUB_KEY")
end
