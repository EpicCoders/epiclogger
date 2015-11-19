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
    counter = 0
    @website = Website.find(website_id)
    @website.grouped_issues.each do |group|
      counter += Issue.where('group_id = ? AND created_at > ?', group.id, Time.now - 1.hour).count
    end
    if counter >= 10
      more_than_10_errors(website_id)
    else
      mail(subject: "EpicLogger Realtime Error",bcc: mail_to(website_id))
    end
  end

  def more_than_10_errors(website_id)
    mail(subject: "EpicLogger Constant Error",bcc: mail_to(website_id))
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
