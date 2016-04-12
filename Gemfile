source 'https://rubygems.org'

ruby '2.2.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.6'
# Use postgres as the database for Active Record
gem 'pg'
# Add enumerize gem
gem 'enumerize'

# Use bootstrap
gem 'bootstrap-sass', '~> 3.3.6'
gem 'font-awesome-sass'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.1'
# Sprokets
gem 'sprockets-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
gem 'haml-rails'

# jquery form validation plugin
gem 'jquery-validation-rails'
gem 'activeadmin', '~> 1.0.0.pre2'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
gem 'gon'
gem 'jquery-turbolinks'
gem 'momentjs-rails'
gem 'nprogress-rails' # loading for turbolinks
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Loading env vars
gem 'figaro'

# awesome replacement for JavaScript's alert.
gem 'sweet-alert'

# Add Kaminari for pagination.
gem 'kaminari'

# Authentication
gem 'rails_warden'
gem 'warden_omniauth'
gem 'omniauth-github'
gem 'cancancan', '~> 1.10'
# Add sidekiq for background jobs
gem 'sidekiq'
gem 'redis-rails'

# add gem for forms
gem 'simple_form'
# add wizard gem
gem 'wicked'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  # gem 'spring'
  # gem 'spring-commands-rspec'
end

group :test do
  gem 'database_cleaner'
  gem 'capybara'
  gem 'timecop'
  gem 'shoulda-matchers', require: false
  gem 'codeclimate-test-reporter', require: false
end

group :development, :test do
  # Add server thin
  gem 'thin'

  gem 'faker'
  gem 'pry'
  gem 'rspec-rails', '~> 3.4.2'
  gem 'factory_girl_rails'

  gem 'brakeman', require: false

  # Let's open the emails in browser
  gem 'letter_opener'
end

group :production, :staging do
  # Heroku features
  gem 'rails_12factor'
  # gem 'asset_sync'
  gem 'rack-host-redirect'
  gem 'heroku-deflater'
  # Use Phusion Passenger for server
  gem 'passenger'
end
