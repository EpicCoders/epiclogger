class Api::V1::SubscribersController < Api::V1::ApiController
  load_and_authorize_resource
  def index
    @subscribers = current_website.subscribers
  end
end
