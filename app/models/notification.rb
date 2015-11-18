class Notification < ActiveRecord::Base
  belongs_to :member

  def self.daily_report
    date = Time.now - 1.day
    Website.select("websites.id").joins(:grouped_issues).where("grouped_issues.updated_at > ?", date).uniq.each do |website|
      UserMailer.notify_daily(website.id).deliver
    end
  end
end