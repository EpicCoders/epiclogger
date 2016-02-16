#!/usr/bin/env bash

cd /var/www 
/home/vagrant/.rvm/wrappers/epiclogger/bundler exec rails s -d -b 0.0.0.0
/home/vagrant/.rvm/wrappers/epiclogger/bundler exec sidekiq -d -L sidekiq.log -q mailer,5 -q default
exit 0