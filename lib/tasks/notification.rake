namespace :notification do

  desc 'notify members daily'
  task :daily => :environment do
    puts "Starting.."
    Website.daily_report
    puts "End. Success."
  end

  desc 'verify hourly'
  task :hourly => :environment do
    puts "Email website users where more than 10 errors happened in the last hour"
    Website.where(frequent_event: true).joins(:issues).where('issues.created_at > ?', Time.now - 1.hour).uniq.each do |website|
      Issue.more_than_10_errors(website)
    end
  end
end