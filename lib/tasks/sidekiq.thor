class Sidekiq < Thor
  option :port, aliases: ['-p'], default: 9292, :type => :numeric,
         desc: 'port that the server will listen on'
  desc 'web heroku_app_or_url', 'Starts a web daemon to view the sidekiq queue'
  long_desc <<-LONGDESC
    This command starts a simple webapp frontend to manage a sidekiq queue.
    Specify either a redis url (beginning with redis://) or a heroku app name to manage.
  LONGDESC
  def web(url_or_heroku_app)
    redis_url = nil
    if /^redis:\/\//.match(url_or_heroku_app)
      redis_url = url_or_heroku_app
    else
      require 'open3'
      Bundler.with_clean_env {
        output, status = Open3.capture2("heroku config -s -a #{url_or_heroku_app}")
        config = {}
        output.split("\n").each do |line|
          parts = line.split("=", 2)
          if /^REDIS/.match(parts[0])
            config[parts[0]] = parts[1]
          end
        end
        unless config['REDIS_PROVIDER'].nil?
          redis_url = config[config['REDIS_PROVIDER']]
        end
      }
    end

    if redis_url.nil?
      puts "ERROR: could not locate redis_url"
    else
      require 'rack'
      ENV['REDIS_URL'] = redis_url
      Rack::Server.start(config: 'config-sidekiq.ru', Port: options[:port])
    end
  end
end
