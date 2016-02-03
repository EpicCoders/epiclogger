web: ./bin/passenger-status-service-agent & bundle exec passenger start -p $PORT --min-instances $WEB_CONCURRENCY --max-pool-size $WEB_CONCURRENCY
sidekiq: bundle exec sidekiq