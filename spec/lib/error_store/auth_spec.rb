require 'rails_helper'

RSpec.describe ErrorStore::Auth do
  xdescribe 'initialize' do
    it 'assigns error'
    it 'calls get_authorization'
  end

  xdescribe 'get_authorization' do
    describe 'POST' do
      it 'raises MissingCredentials if HTTP_X_SENTRY_AUTH or HTTP_AUTHORIZATION are missing'
      it 'checks HTTP_X_SENTRY_AUTH for Sentry string and returns parsed'
      it 'checks HTTP_AUTHORIZATION for Sentry string and returns parsed'
      it 'raises MissingCredentials if auth_req is blank'
      it 'sets sentry_client from HTTP_USER_AGENT if not set'
      it 'assigns variables from auth_req'
      it 'assigns the CURRENT_VERSION if version not set'
    end

    describe 'GET' do
      # TODO, add more when logic is added
      it 'raises MissingCredentials if auth_req is blank'
      it 'sets sentry_client from HTTP_USER_AGENT if not set'
      it 'assigns variables from auth_req'
      it 'assigns the CURRENT_VERSION if version not set'
    end
  end

  xdescribe 'parse_auth_header' do
    it 'returns a hash with values from string'
  end

  xdescribe '_error' do
    it 'returns the assigned error'
  end
end
