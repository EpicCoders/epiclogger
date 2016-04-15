class IntegrationsAuthController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:success]

  def create

  end
end
