class Api::V1::NotificationsController < Api::V1::ApiController
  skip_before_action :authenticate_member!, only: [:create]

  def show
    @notification = current_member.notification
  end

  def update
    @notification = Notification.find(params[:id])
    @notification.update_attributes(notification_params)
  end

  private
  def notification_params
    params.require(:notification).permit(:id, :member_id, :daily_reports, :realtime_error, :when_event)
  end
end
