class HomeController < ApplicationController
  layout "landing"
  # is this skip really needed here?
  skip_before_action :authenticate_member!

  def index; end
end
