class Api::V1::NotificationsController < Api::V1::ApiController
  load_and_authorize_resource
  skip_before_action :authenticate_member!, only: [:create]

  def index
    @notification = current_site.notification
  end

  def update
    binding.pry
    @notification.update_attributes(notification_params)
  end

  private

  def notification_params
    params.require(:notification).permit(:id, :member_id, :daily, :realtime, :new_event, :frequent_event)
  end
end
