# EpicLogger

[![Dependency Status](https://gemnasium.com/EpicCoders/epiclogger.svg)](https://gemnasium.com/EpicCoders/epiclogger)
[![Code Climate](https://codeclimate.com/github/EpicCoders/epiclogger/badges/gpa.svg)](https://codeclimate.com/github/EpicCoders/epiclogger)
[![Test Coverage](https://codeclimate.com/github/EpicCoders/epiclogger/badges/coverage.svg)](https://codeclimate.com/github/EpicCoders/epiclogger/coverage)
[![Build Status](https://travis-ci.org/EpicCoders/epiclogger.svg)](https://travis-ci.org/EpicCoders/epiclogger)

## EpicLogger engage developers with users to solve errors

I would love if we could build a product that helps developers talk to users of a product and notify them when errors are fixed or talk to them and get information about an issue they might have. I find myself, in cases of bigger companies, where i have to get to support to get that information or in cases of small companies where i have to use multiple products to find what users are having a certain problem and then notify them when it's fixed.

## Contributing

The easiest way to install EpicLogger locally is by using the Vagrant image:

  1. Install [Vagrant](https://www.vagrantup.com/downloads.html) and [VirtualBox](https://www.virtualbox.org/wiki/Downloads).
  2. Clone the EpicCoders/epiclogger repository and set up the Vagrant box:

        git clone --recursive https://github.com/EpicCoders/epiclogger.git
        cd epiclogger/railsbox/development
        vagrant up

  3. Add an entry to your /etc/hosts file: 192.168.20.50 epiclogger.dev __OR__ just use [localhost:8080](http://localhost:8080)
  4. Visit [epiclogger.dev](http://epiclogger.dev) || [localhost:8080](http://localhost:8080) in a browser.

If you can't use vagrant on your system then you need to follow the below Installation guide and install all the required libraries.

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

