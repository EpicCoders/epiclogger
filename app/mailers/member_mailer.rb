class MemberMailer < ApplicationMailer
  default from: 'notifications@example.com'

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
