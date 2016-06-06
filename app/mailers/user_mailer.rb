class UserMailer < ApplicationMailer
  default from: "Epic Logger <admin@epiclogger.com>"

  def reset_password(user)
    @user = user
    mail(to: @user.email, subject: "Epic Logger reset password")
  end

  def email_confirmation(user)
    return if user.confirmed?
    @user = user
    mail(to: @user.email, subject: "Epic Logger email confirmation")
  end

  def member_invitation(invite)
    @invite = invite
    @inviter = @invite.inviter
    @website = @invite.website
    mail(to: @invite.email, subject: 'Epic Logger Invite Users')
  end
end
