# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  def notify_subscriber
    message = Message.last
    UserMailer.notify_subscriber(message.issue, message.subscriber, message.content)
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
