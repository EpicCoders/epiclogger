if ENV['EPICLOGGER_FULL_DSN'].present? && !Rails.env.test?
  Raven.configure do |config|
    config.dsn = ENV['EPICLOGGER_FULL_DSN']
    config.current_environment = Rails.env
    config.tags = { environment: Rails.env }
  end
end