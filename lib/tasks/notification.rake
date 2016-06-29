namespace :notification do

  desc 'notify members weekly'
  task :weekly => :environment do
    puts "Starting.."
    t = Time.now.utc
    Website.custom_report(t - 1.week, 'weekly_reporting') if t.sunday?
    puts "End. Success."
  end

  desc 'notify members daily'
  task :daily => :environment do
    puts "Starting.."
    date = Time.now.utc - 1.day
    Website.custom_report(date, 'daily_reporting')
    puts "End. Success."
  end

  desc 'notify members hourly'
  task :hourly => :environment do
    puts "Email website users where more than 10 errors happened in the last hour"
    WebsiteMember.with_frequent_event.joins(website: :issues).where('issues.created_at > ?', Time.now - 1.hour).uniq.each do |member|
      Issue.more_than_10_errors(member)
    end
  end
end