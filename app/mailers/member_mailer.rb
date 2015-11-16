class MemberMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def error_occurred(website_id, type)
    @website = Website.find(website_id)
    @type = type
    @subsribers = @website.subscribers.map { |m| "<#{m.email}>"  }
    mail(subject: "EpicLogger Realtime Error",bcc: @subscribers)
  end

  def notify_daily(website_id)
    @website = Website.find(website_id)
    @subsribers = @website.subscribers.map { |m| "<#{m.email}>"  }
    mail(subject: "EpicLogger Daily Reports",bcc: @subscribers)
  end
end
