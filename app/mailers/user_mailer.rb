class UserMailer < ApplicationMailer

  def notify_subscriber(issue, subscriber, message)
    @issue = issue
    @message = message
    @website = Website.find(@issue.website_id)
    @member = subscriber
    mail(to: @member.email, subject: 'Subscriber notification')
  end

  def subscriber_invitation(website, email, inviter)
    @member = inviter
    @website = website
    @subscriber_email = email
    mail(to: @subscriber_email, subject: 'Invite Subscribers')
  end

end
