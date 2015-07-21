class UserMailer < ApplicationMailer

  def issue_solved(issue, subscriber)
    @issue = issue
    @website = Website.find(@issue.website_id)
    @member = subscriber
    pry
    mail(to: @member.email, subject: 'Issue Solved')
  end

end
