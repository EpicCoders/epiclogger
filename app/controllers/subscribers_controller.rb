class SubscribersController < ApplicationController
	load_and_authorize_resource
  def index
    @subscribers = current_website.subscribers
  end

  def destroy
    binding.pry
    @subscriber.destroy
    respond_to do |format|
      format.js { render inline: 'location.reload();' }
    end
  end
end
