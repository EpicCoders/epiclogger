class Api::V1::SubscribersController < Api::V1::ApiController

  def index
    @subscribers = current_site.subscribers
  end

  def create
  end

  def destroy
    @subscriber = Subscriber.find(params[:id])
    @subscriber.destroy()
  end

  private
    def subscriber_params
      params.require(:subscriber).permit(:name, :email, :role, :website_id)
    end
end
