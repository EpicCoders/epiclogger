class UserMailer < ApplicationMailer

  def notify_subscriber(issue, subscriber, message)
    @issue = issue
    @message = message
    @website = Website.find(@issue.website_id)
    @member = subscriber
    mail(to: @member.email, subject: 'Subscriber notification')
  end

  def member_invitation(website, email, invitation_token, inviter)
    @member = inviter
    @website = website
    @token = invitation_token
    mail(to: email, subject: 'Invite Members')
  end

end
