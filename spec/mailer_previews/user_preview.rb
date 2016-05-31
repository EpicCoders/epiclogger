# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  def email_confirmation
    show_email do
      @mail = UserMailer.email_confirmation(@user).message
    end
  end

  def error_occurred
    show_email do
      @mail = UserMailer.error_occurred(@issue).message
    end
  end

  def reset_password
    show_email do
     @mail = UserMailer.reset_password(@user).message
    end
  end

  def notify_subscriber
    show_email do
      @mail = UserMailer.notify_subscriber(@group, @user, 'current@user.com', 'I think i know the solution').message
    end
  end

  def member_invitation
    show_email do
      @mail = UserMailer.member_invitation(@invite).message
    end
  end

  def more_than_10_errors
    show_email do
      @mail = UserMailer.more_than_10_errors(@website.id, @message.id).message
    end
  end

  def event_occurred
    show_email do
      @mail = UserMailer.event_occurred(@group).message
    end
  end

  def notify_daily
    show_email do
      @mail = UserMailer.notify_daily(@website).message
    end
  end

  protected

  def show_email(&block)
    @mail = nil
    ActiveRecord::Base.transaction do
      @user = User.create!(name: 'Bob User', email: 'preview_user@example.com', provider: 'email', password: 'password', password_confirmation: 'password', reset_password_token: 'KlQFgx2ckDmJsvnbbj3CRw', confirmed_at: Time.now, confirmation_token: 'vJq2UGPUDBZYcO7RiuxkAw')
      @website = Website.create!(domain: 'http://website.com', title: 'Website')
      @invite = Invite.create!(website: @website, invited_by_id: @user.id, email: 'user@invite.com', token: '4zZrL22B6FtRUOU5CJVVbA')
      @website_member = WebsiteMember.create!(user: @user, website: @website)
      @group = GroupedIssue.create!(website_id: @website.id, culprit: 'index.php:Raven_ErrorHandler in handleError', message: 'Undefined variable: ex', created_at: Time.now, checksum: '5ae79a60e5a97b0977e01b525c779e49')
      @subscriber = Subscriber.create!(website_id: @website.id, email: 'subscriber@test.com', name: 'Unnamed')
      @issue = Issue.create!(website_id: @website.id, subscriber_id: @subscriber.id, group_id: @group.id, message: 'Message that something went wrong', created_at: Time.now)

      yield

      raise ActiveRecord::Rollback
    end
    @mail
  end
end
