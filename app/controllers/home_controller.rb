class HomeController < ApplicationController
  layout "landing"
  skip_authorization_check
  # is this skip really needed here?

  def index; end
end
