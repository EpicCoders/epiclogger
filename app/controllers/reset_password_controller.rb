class ResetPasswordController < ApplicationController
  layout "landing"
  skip_before_action :authenticate!, :only => [:new, :create, :edit]

  def new
  end

  def create
    if user_params[:email].blank?
      flash[:alert] = 'Specify an email address'
      render :new
    else
      user = User.find_by_email(user_params[:email])

      # Send a reset password instructions if user exists
      if user
        user.send_reset_password

        flash[:notice] = 'Email sent with password reset instructions'
      else
        flash[:notice] = 'No such user here'
      end
      redirect_to :login
    end
  end

  def edit
    @user = User.find_by_reset_password_token(params[:id])

    if @user && @user.reset_password_sent_at.utc >= 5.days.ago
      if user_params[:password] == user_params[:password_confirmation]
        @user.update_attributes(user_params)
        flash[:notice] = 'Your password has been changed'
      end
    else
      flash[:notice] = "Period Expired"
    end
    redirect_to :login
  end

  protected

  def user_params
    @params ||= params.require(:user).permit(:id, :email, :password, :password_confirmation)
  end
end