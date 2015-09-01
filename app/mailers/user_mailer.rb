class UserMailer < ApplicationMailer

  def notify_subscriber(issue, subscriber, message)
    @issue = issue
    @message = message
    @website = Website.find(@issue.website_id)
    @member = subscriber
    mail(to: @member.email, subject: 'Subscriber notification')
  end

  def member_invitation(website_id, email, invitation_token, inviter_id)
    @member = Member.find(inviter_id)
    @website = Website.find(website_id)
    @token = invitation_token
    @email = email
    mail(to: @email, subject: 'Invite Members')
  end

end
