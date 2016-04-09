class Api::V1::StoreController < Api::V1::ApiController
  def create
    @error_store = ErrorStore.create!(request)
  rescue ErrorStore::MissingCredentials => e
    _not_allowed! e.message
  end
end
