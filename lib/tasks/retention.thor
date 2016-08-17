class Retention < Thor
  require File.expand_path('config/environment.rb')
  desc 'remove errors', 'remove old errors based on users plans'
  def remove_errors
    puts 'Starting..'
    GroupedIssue.where('last_seen <= ?', Time.now - 1.month).destroy_all
    puts 'End. Success.'
  end
end