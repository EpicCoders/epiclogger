redis_url = ENV['REDISCLOUD_URL'] || ENV['REDIS_URL'] || 'redis://127.0.0.1:6379/0/pxls'
Epiclogger::Application.config.cache_store = :redis_store, redis_url, { expires_in: 1.hour }
