if ENV['EPICLOGGER_DSN'].present?
  Raven.configure do |config|
    config.dsn = ENV['EPICLOGGER_DSN']
    config.current_environment = Rails.env
    config.tags = { environment: Rails.env }
  end
end