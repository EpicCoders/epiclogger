class MemberMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def notify_daily(website_id)
    @website = Website.find(website_id)
    @subsribers = @website.subscribers.map { |m| "<#{m.email}>"  }
    mail(subject: "EpicLogger Daily Reports",bcc: @subscribers)
  end
end
