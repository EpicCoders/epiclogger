class Notification < Thor
  require File.expand_path('config/environment.rb')
  desc 'report_weekly', 'notify website members weekly'
  def report_weekly
    puts 'Starting..'
    t = Time.now.utc
    Website.custom_report(t - 1.week, :weekly) if t.sunday?
    puts 'End. Success.'
  end

  desc 'report_daily', 'notify website members daily'
  def report_daily
    puts 'Starting..'
    date = Time.now.utc
    Website.custom_report(date - 1.day, :daily)
    puts 'End. Success.'
  end

  desc 'report_hourly', 'notify website members hourly'
  def report_hourly
    puts 'Email website users where more than 10 errors happened in the last hour'
    WebsiteMember.with_frequent_event
      .joins(website: :issues)
      .where('issues.created_at > ?', Time.now - 1.hour)
      .uniq.find_each(batch_size: 500) do |member|
      Issue.more_than_10_errors(member)
    end
  end
end
