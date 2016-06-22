class SubscribersController < ApplicationController
	load_and_authorize_resource
  def index
    @subscribers = current_website.subscribers
  end

  def destroy
    @subscriber.destroy
    redirect_to subscribers_url
  end
end
