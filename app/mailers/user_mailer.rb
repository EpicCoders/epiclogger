class UserMailer < ApplicationMailer

  def issue_solved(issue, subscriber, message)
    @issue = issue
    @message = message
    @website = Website.find(@issue.website_id)
    @member = subscriber
    mail(to: @member.email, subject: 'Notification from a subscriber')
  end

end
