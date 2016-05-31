class UserMailer < ApplicationMailer
  default from: "Epic Logger <admin@epiclogger.com>"

  def reset_password(user)
    @user = user
    mail(to: @user.email, subject: "Epic Logger reset password")
  end

  def email_confirmation(user)
    #comment this line when previewing
    return if user.confirmed?
    @user = user
    mail(to: @user.email, subject: "Epic Logger email confirmation")
  end

  def notify_subscriber(group, user, sender, message)
    @sender = sender
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

  def error_occurred(issue)
    counter = 0
    @issue = issue
    @website = issue.website
    @website.grouped_issues.each do |group|
      counter += Issue.where('group_id = ? AND created_at > ?', group.id, Time.now - 1.hour).count
    end
    if counter >= 10
      more_than_10_errors(@website.id, message_id)
    else
      mail(subject: "Epic Logger Realtime Error",bcc: mail_to(@website))
    end
  end

  def more_than_10_errors(message)
    @message = message
    mail(subject: "EpicLogger Constant Error",bcc: mail_to(@message.issue.website))
  end

  def event_occurred(group)
    @group = group
    mail(subject: "Epic Logger Event Occurred",bcc: mail_to(@group.website))
  end

  def notify_daily(website)
    mail(subject: "Epic Logger Daily Reports",bcc: mail_to(website))
  end

  def mail_to(website)
    @website = website
    return @website.users.map { |m| "<#{m.email}>"  }
  end
end
