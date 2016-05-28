class UserMailer < ApplicationMailer
  default from: "Epic Logger <admin@epiclogger.com>"

  def reset_password(user)
    @user = user
    mail(to: @user.email, subject: "Epic Logger reset password")
  end

  def email_confirmation(user)
    return if user.confirmed?
    @user = user
    mail(to: @user.email, subject: "Epic Logger email confirmation")
  end

  def notify_subscriber(group, user, message)
    @group = group
    @message = message
    @website = @group.website
    @user = user
    mail(to: @user.email, subject: 'Epic Logger Subscriber notification')
  end

  def member_invitation(invite)
    @invite = invite
    @inviter = @invite.inviter
    @website = @invite.website
    mail(to: @invite.email, subject: 'Epic Logger Invite Users')
  end

  def error_occurred(website_id, message_id)
    counter = 0
    @message = Message.find(message_id)
    @website = Website.find(website_id)
    @website.grouped_issues.each do |group|
      counter += Issue.where('group_id = ? AND created_at > ?', group.id, Time.now - 1.hour).count
    end
    if counter >= 10
      more_than_10_errors(website_id, message_id)
    else
      mail(subject: "Epic Logger Realtime Error",bcc: mail_to(website_id))
    end
  end

  def more_than_10_errors(website_id, message_id)
    @message = Message.find(message_id)
    mail(subject: "EpicLogger Constant Error",bcc: mail_to(website_id))
  end

  def event_occurred(website_id, group_id)
    @group = GroupedIssue.find(group_id)
    mail(subject: "Epic Logger Event Occurred",bcc: mail_to(website_id))
  end

  def notify_daily(website_id)
    mail(subject: "Epic Logger Daily Reports",bcc: mail_to(website_id))
  end

  def mail_to(website_id)
    @website = Website.find(website_id)
    return @website.users.map { |m| "<#{m.email}>"  }
  end
end
