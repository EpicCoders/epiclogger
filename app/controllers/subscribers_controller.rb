class SubscribersController < ApplicationController
  def index
    @subscribers = current_website.subscribers
  end
end
