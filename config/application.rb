require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Epiclogger
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'UTC'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.autoload_paths << Rails.root.join('lib')

    cache_url = ENV['MEMCACHEDCLOUD_SERVERS'] || 'localhost:11211'
    config.cache_store = :dalli_store, cache_url.split(','), {
      namespace: 'epiclogger',
      expires_in: 1.hour,
      compress: true,
      username: ENV['MEMCACHEDCLOUD_USERNAME'],
      password: ENV['MEMCACHEDCLOUD_PASSWORD']
    }

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.action_dispatch.default_headers.merge!({
      'Access-Control-Allow-Origin' => '*',
      'Access-Control-Request-Method' => '*'
    })
  end
end
