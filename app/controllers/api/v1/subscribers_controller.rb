class Api::V1::SubscribersController < Api::V1::ApiController

  def index
    @subscribers = current_site.subscribers
  end

  def create
  end
  private
		def subscriber_params
			params.require(:subscriber).permit(:name, :email, :role, :website_id)
		end
end
