# EpicLogger

[![Dependency Status](https://gemnasium.com/EpicCoders/epiclogger.svg)](https://gemnasium.com/EpicCoders/epiclogger)
[![codecov](https://codecov.io/gh/EpicCoders/epiclogger/branch/master/graph/badge.svg)](https://codecov.io/gh/EpicCoders/epiclogger)
[![Build Status](https://travis-ci.org/EpicCoders/epiclogger.svg?branch=master)](https://travis-ci.org/EpicCoders/epiclogger)

## EpicLogger engage developers with users to solve errors

EpicLogger is the open source product that offers error logging and customer support with ease. You can add integrations like intercom and github to manage the errors you are getting from your application and then notify your customers when those errors are fixed.

## EpicLogger website

You don't want to install the app on your server? You can use our installed app here: [http://epiclogger.com](http://epiclogger.com) and make an account. We are currently in beta and evolving day by day.

[![Epiclogger](http://i.imgur.com/VYTFliv.png?1)](http://epiclogger.com)

## Contributing

The easiest way to install EpicLogger locally is by using the Vagrant image:

  1. Install [Vagrant](https://www.vagrantup.com/downloads.html) and [VirtualBox](https://www.virtualbox.org/wiki/Downloads).
  2. Clone the EpicCoders/epiclogger repository and set up the Vagrant box:

        git clone --recursive https://github.com/EpicCoders/epiclogger.git
        cd epiclogger/railsbox/development
        vagrant plugin install vagrant-hostmanager
        vagrant up

  3. Add an entry to your /etc/hosts file: 192.33.33.33 epiclogger.dev __OR__ just use [localhost:8080](http://localhost:8080)
  4. Visit [epiclogger.dev](http://epiclogger.dev) || [localhost:8080](http://localhost:8080) in a browser.

If you can't use vagrant on your system then you need to follow the below Installation guide and install all the required libraries.

If the app doesn't run you need to go and run ```vagrant ssh``` in your terminal on the same folder and then once you are in run ```sudo start epiclogger```.

### Instalation guide

#### OSX

*requirements: you need postgresql installed and the rails gem. A tutorial that gives options for all databases is here: http://techblog.floorplanner.com/how-to-install-rvm-ruby-rails-mysql-mongodb-on-mac/ we only need postgresql*

#### WINDOWS

*requirements: you need postgresql and rails. Easier to install is by running this: http://railsinstaller.org/en*

##### Commands to run for both platforms

1. `bundle` run it in the directory where you cloned the repository
1. `rake db:setup` will create the database and run the migrations
1. `rake db:seed` will add the starting data to your local database so you can get started right away
1. `rails s` will start the server and you can now visit `http://localhost:3000` in your browser to view the main page
1. login with: `chocksy@gmail.com | password` to view the dashboard

### Pull requests are welcome!

If you are interested in heping us and have any new ideas we are welcome to any pull request.

## Are you interested in helping?

Here is what you need to get started:

### Developer

__if you are a developer then you would need the following knowledge:__
- CSS, JS & HTML to code some of our frontend
- Ruby on Rails to write our API's and backend
- Bootstrap css framework to know a little

### Designer

- Design taste and not a lot of experience we are going to review each submission

### Marketing

- If you are a marketing person then we are going to have multiple bounties for you where you can share or work on social interaction tasks. 

If nothing fits then just jump on chat and we'll find something with some nice coins to get started.

