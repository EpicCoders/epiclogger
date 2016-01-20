namespace :notification do

  desc 'notify members daily'
  task :daily => :environment do
    puts "Starting.."
    Website.daily_report
    puts "End. Success."
  end
end