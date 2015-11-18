class UserMailer < ApplicationMailer

  def notify_subscriber(issue, subscriber, message)
    @issue = issue
    @message = message
    @website = Website.find(@issue.website_id)
    @member = subscriber
    mail(to: @member.email, subject: 'Subscriber notification')
  end

  def member_invitation(website_id, email, website_member_id, inviter_id)
    @member = Member.find(inviter_id)
    @website = Website.find(website_id)
    @token = WebsiteMember.find(website_member_id).invitation_token
    @email = email
    mail(to: @email, subject: 'Invite Members')
  end

  def error_occurred(website_id)
    mail(subject: "EpicLogger Realtime Error",bcc: mail_to(website_id))
  end

  def event_occurred(website_id)
    mail(subject: "EpicLogger Event Occurred",bcc: mail_to(website_id))
  end

  def notify_daily(website_id)
    mail(subject: "EpicLogger Daily Reports",bcc: mail_to(website_id))
  end

  def mail_to(website_id)
    @website = Website.find(website_id)
    return @website.subscribers.map { |m| "<#{m.email}>"  }
  end

end
