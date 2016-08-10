class Maintenance < Thor
  require File.expand_path('config/environment.rb')
  desc 'add_environment', 'update columns with the missing environment'
  def add_environment
    puts 'Starting..'
    GroupedIssue.all.each do |group|
      if group.environment.nil?
        env = group.issues.first.try(:environment)
        group.update_attributes(environment: env) unless env.nil?
      end
    end
    puts 'End. Success.'
  end
end