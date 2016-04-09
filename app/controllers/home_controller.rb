class HomeController < ApplicationController
  layout "landing"
  skip_before_action :authenticate!

  def index; end
end
