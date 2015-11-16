namespace :notification do

  desc 'notify members daily'
  task :daily => :environment do
    puts "Starting.."
    Notification.daily_report
    puts "End. Success."
  end
end