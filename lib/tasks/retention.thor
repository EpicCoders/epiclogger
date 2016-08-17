class Retention < Thor
  require File.expand_path('config/environment.rb')
  desc 'remove errors', 'remove old errors based on users plans'
  def remove_errors
    puts 'Starting..'
    GroupedIssue.where('first_seen <= ?', Time.now - 1.week).destroy_all
    puts 'End. Success.'
  end
end