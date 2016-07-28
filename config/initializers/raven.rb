if ENV['RUBY_DSN'].present? && !Rails.env.test?
  Raven.configure do |config|
    config.dsn = ENV['RUBY_DSN']
    config.current_environment = Rails.env
    config.tags = { environment: Rails.env }
  end
end