class GroupedIssueMailer < ApplicationMailer
  default from: "Epic Logger <admin@epiclogger.com>"
  def notify_subscriber(group, user, sender, message)
    @sender = sender
    @group = group
    @message = message
    @user = user
    mail to: @user.email, subject: 'Epic Logger Subscriber notification'
  end

  def error_occurred(issue, member)
    @issue = issue
    @website = member.website
    mail to: member.user.email, subject: 'Epic Logger Realtime Error'
  end

  def more_than_10_errors(member)
    @website = member.website
    @last_hour_errors = @website.issues.where('issues.created_at > ?', Time.now - 1.hour)
    if @last_hour_errors.count >= 10
      mail to: member.user.email, subject: 'EpicLogger Constant Error'
    end
  end

  def notify_daily(member)
    date = Time.now - 1.day
    @website = member.website
    @grouped_issues = @website.grouped_issues.where('updated_at > ?', date)
    mail to: member.user.email, subject: 'Epic Logger Daily Reports'
  end

  def notify_weekly(member)
    date = Time.now - 1.week
    @website = member.website
    @grouped_issues = @website.grouped_issues.where('updated_at > ?', date)
    mail to: member.user.email, subject: 'Epic Logger Daily Reports'
  end
end
