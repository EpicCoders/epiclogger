class Notification < ActiveRecord::Base
  belongs_to :member
  belongs_to :website
  has_many :members, through: :website_members
  has_many :website_members, dependent: :destroy, autosave: true

  def self.daily_report
    date = Time.now - 1.day
    Website.select("websites.id").joins(:grouped_issues).where("grouped_issues.updated_at > ?", date).uniq.each do |website|
      UserMailer.notify_daily(website.id).deliver_now
    end
  end
end