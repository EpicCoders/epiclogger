class GroupedIssueMailer < ApplicationMailer
   def notify_subscriber(group, user, sender, message)
    @sender = sender
    @group = group
    @message = message
    @website = @group.website
    @user = user
    mail(to: @user.email, subject: 'Epic Logger Subscriber notification')
  end

  def error_occurred(issue)
    @issue = issue
    @website = issue.website
    mail(subject: "Epic Logger Realtime Error",bcc: mail_to(@website))
  end

  def more_than_10_errors(last_hour_issues)
    @last_hour_issues = last_hour_issues
    mail(subject: "EpicLogger Constant Error",bcc: mail_to(@last_hour_issues[0].website))
  end

  def event_occurred(group)
    @group = group
    mail(subject: "Epic Logger Event Occurred",bcc: mail_to(@group.website))
  end

  def notify_daily(grouped_issues)
    @grouped_issues = grouped_issues
    @website = @grouped_issues.first.website
    mail(subject: "Epic Logger Daily Reports",bcc: mail_to(@website))
  end

  def mail_to(website)
    @website = website
    return @website.users.map { |u| "<#{u.email}>"  }
  end
end
