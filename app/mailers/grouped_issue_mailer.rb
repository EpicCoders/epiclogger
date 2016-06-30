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
    @member = member
    mail to: @member.user.email, subject: 'Epic Logger Realtime Error'
  end

  def more_than_10_errors(member)
    @member = member
    @last_hour_errors = @member.website.issues.where('issues.created_at > ?', Time.now - 1.hour)
    if @last_hour_errors.count >= 10
      mail to: @member.user.email, subject: 'EpicLogger Constant Error'
    end
  end

  def notify_daily(member)
    date = Time.now - 1.day
    @member = member
    @grouped_issues = @member.website.grouped_issues.where('updated_at > ?', date)
    mail to: @member.user.email, subject: 'Epic Logger Daily Reports'
  end

  def notify_weekly(member)
    date = Time.now - 1.week
    @member = member
    grouped_issues = @member.website.grouped_issues.where('updated_at > ?', date)

    @weekly_updates = []
    @days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']
    @days.each do |day|
      @weekly_updates.push(grouped_issues.select { |group| group.updated_at.public_send(day+'?') })
    end

    mail to: @member.user.email, subject: 'Epic Logger Weekly Reports'
  end
end
