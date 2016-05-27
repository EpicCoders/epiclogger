class ResetPasswordController < ApplicationController
  layout "landing"
  skip_before_action :authenticate!

  def new; end

  def create
    if user_params[:email].blank?
      flash[:alert] = 'Specify an email address'
      render :new
    else
      user = User.find_by_email(user_params[:email])

      # Send a reset password instructions if user exists
      if user
        user.send_reset_password

        flash[:alert] = 'Email sent with password reset instructions'
        redirect_to :login
      else
        flash[:alert] = 'No such user here'
        render :new
      end
    end
  end

  def edit
    @user = User.find_by_reset_password_token(params[:id])
    if @user.nil?
      flash[:alert] = 'User not found'
      redirect_to :login
    end
  end

  def update
    @user = User.find_by_reset_password_token(params[:id])

    if @user && @user.reset_password_sent_at.utc >= 5.days.ago
      if user_params[:password] == user_params[:password_confirmation]
        @user.update_attributes(user_params)
        flash[:alert] = 'Your password has been changed'
      end
    else
      flash[:alert] = "Period expired or Password don't match"
    end
    redirect_to :login
  end

  protected

  def user_params
    @params ||= params.require(:user).permit(:id, :email, :password, :password_confirmation)
  end
end