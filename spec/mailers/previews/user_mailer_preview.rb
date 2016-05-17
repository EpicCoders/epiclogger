# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  def member_invitation
    @user = User.first
    @website = Website.first
    @token = WebsiteMember.first.invitation_token
    @email = 'email@example.com'
    mail(to: @email, subject: 'Epic Logger Invite Users')
  end

  def notify_subscriber
    message = 'Custom message sent to members'
    group = GroupedIssue.first
    UserMailer.notify_subscriber(group, group.website.members.first, message)
  end

  def member_invitation
    website = Website.first
    member = Member.first
    website_member = WebsiteMember.last
    UserMailer.member_invitation(website.id, 'test@preview.com',website_member.id, member.id )
  end

  def error_occurred
    message = Message.last
    website = message.issue.group.website
    UserMailer.error_occurred(website.id, message.id)
  end

  def more_than_10_errors
    message = Message.last
    website = message.issue.group.website
    UserMailer.more_than_10_errors(website.id, message.id)
  end

  def notify_daily
    UserMailer.notify_daily(Website.last.id)
  end
end
