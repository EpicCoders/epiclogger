# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  def email_confirmation
    show_email do
      UserMailer.email_confirmation(@user).message
    end
  end

  def error_occurred
    show_email do
      UserMailer.error_occurred(@website.id, @message.id).message
    end
  end

  def reset_password
    show_email do
      UserMailer.reset_password(@user).message
    end
  end

  def notify_subscriber
    show_email do
      UserMailer.notify_subscriber(@group, @user, @message).message
    end
  end

  def member_invitation
    show_email do
      UserMailer.member_invitation(@invite).message
    end
  end

  def more_than_10_errors
    show_email do
      UserMailer.more_than_10_errors(@website.id, @message.id).message
    end
  end

  def event_occurred
    show_email do
      UserMailer.event_occurred(@website.id, @group.id).message
    end
  end

  def notify_daily
    show_email do
      UserMailer.notify_daily(@website.id).message
    end
  end

  protected

  def show_email(&block)
    @mail = nil
    ActiveRecord::Base.transaction do
      @user = User.create!(name: 'Bob User', email: 'preview_user@example.com', provider: 'email', password: 'password', password_confirmation: 'password', reset_password_token: 'token')
      @website = Website.create!(domain: 'http://website.com', title: 'Website')
      @invite = Invite.create!(website: @website, invited_by_id: @user.id, email: 'user@invite.com', token: '4zZrL22B6FtRUOU5CJVVbA')
      @website_member = WebsiteMember.create!(user: @user, website: @website)
      @group = GroupedIssue.create!(website_id: @website.id)
      @subscriber = Subscriber.create!(website_id: @website.id, email: 'subscriber@test.com', name: 'Unnamed')
      @issue = Issue.create!(website_id: @website.id, subscriber_id: @subscriber.id, group_id: @group.id, message: 'Message that something went wrong')
      @message = Message.create!(content: 'Custom message for subscribers',issue_id: @issue.id)

      yield

      raise ActiveRecord::Rollback
    end
    @mail
  end
end
