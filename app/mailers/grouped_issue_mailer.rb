class GroupedIssueMailer < ApplicationMailer
  default from: "Epic Logger <admin@epiclogger.com>"
  def notify_subscriber(group, user, sender, message)
    @sender = sender
    @group = group
    @message = message
    @user = user
    mail to: @user.email, subject: 'Epic Logger Subscriber notification'
  end

  def error_occurred(issue)
    @issue = issue
    @website = issue.website
    mail to: website_owners_emails(@website), subject: 'Epic Logger Realtime Error'
  end

  def more_than_10_errors(website)
    @website = website
    @last_hour_errors = @website.issues.where('issues.created_at > ?', Time.now - 1.hour)
    if @last_hour_errors.count >= 10
      mail to: website_owners_emails(@website), subject: 'EpicLogger Constant Error'
    end
  end

  def event_occurred(group)
    @group = group
    mail to: website_owners_emails(@group.website), subject: 'Epic Logger Event Occurred'
  end

  def notify_daily(website)
    date = Time.now - 1.day
    @website = website
    @grouped_issues = @website.grouped_issues.where('updated_at > ?', date)
    mail to: website_owners_emails(@website), subject: 'Epic Logger Daily Reports'
  end

  def website_owners_emails(website)
    website.users.map { |u| "#{u.name} <#{u.email}>" }
  end
end
