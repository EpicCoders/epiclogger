JsRoutes.setup do |config|
  config.default_url_options  = {:host => ENV['MAILER_HOST']}
  config.url_links            = true
  # config.prefix               = "http://#{ENV['MAILER_HOST']}"
  config.exclude              = [/admin/]
end