require 'rails_helper'

RSpec.describe ErrorStore::Auth do
  let(:website) { create :website }
  let(:group) { create :grouped_issue, website: website }
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_error) { create :issue, subscriber: subscriber, group: group, event_id: '8af060b2986f5914764d49b7f39b036c' }
  let(:error) { ErrorStore::Error.new(request: ActionDispatch::Request.new('REQUEST_METHOD' => 'POST','HTTP_USER_AGENT'=>'Faraday v0.9.2','REMOTE_ADDR'=>'127.0.0.1','HTTP_X_SENTRY_AUTH' => "Sentry sentry_version='5', sentry_client='raven-ruby/0.15.2',sentry_timestamp=1455616740, sentry_key=#{website.app_key}, sentry_secret=#{website.app_secret}",'HTTP_ACCEPT_ENCOaDING' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3','rack.input' => StringIO.new(Base64.strict_encode64(Zlib::Deflate.deflate(issue_error.data))))) }

  describe 'initialize' do
    it 'assigns error' do
      expect( ErrorStore::Auth.new(error).instance_variable_get(:@error) ).to eq(error)
    end
    it 'calls get_authorization' do
      expect_any_instance_of(ErrorStore::Auth).to receive(:get_authorization)
      ErrorStore::Auth.new(error)
    end
  end
  describe 'get_authorization' do
    describe 'POST' do
      it 'raises MissingCredentials if HTTP_X_SENTRY_AUTH or HTTP_AUTHORIZATION are missing' do
        error.request.env.delete "HTTP_X_SENTRY_AUTH"
        error.request.env.delete "HTTP_AUTHORIZATION"
        expect { ErrorStore::Auth.new(error) }.to raise_exception(ErrorStore::MissingCredentials)
      end

      it 'checks HTTP_X_SENTRY_AUTH for Sentry string and returns parsed' do
        expect( ErrorStore::Auth.new(error).parse_auth_header(error.request.headers['HTTP_X_SENTRY_AUTH']) ).to eq({"sentry_version"=>"'5'", "sentry_client"=>"'raven-ruby/0.15.2'", "sentry_timestamp"=>"1455616740", "sentry_key"=>"#{website.app_key}", "sentry_secret"=>"#{website.app_secret}"})
      end

      it 'checks HTTP_AUTHORIZATION for Sentry string and returns parsed' do
        error.request.headers['HTTP_AUTHORIZATION'] = error.request.headers['HTTP_X_SENTRY_AUTH']
        error.request.headers['HTTP_X_SENTRY_AUTH'] = ''
        expect( ErrorStore::Auth.new(error).parse_auth_header(error.request.headers['HTTP_AUTHORIZATION']) ).to eq({"sentry_version"=>"'5'", "sentry_client"=>"'raven-ruby/0.15.2'", "sentry_timestamp"=>"1455616740", "sentry_key"=>"#{website.app_key}", "sentry_secret"=>"#{website.app_secret}"})
      end
      it 'raises MissingCredentials if auth_req is blank' do
        ##TODO HOWTO??
      end

      it 'sets sentry_client from HTTP_USER_AGENT if not set' do
        error.request.headers['HTTP_X_SENTRY_AUTH'] = 'Sentry sentry_version=5,sentry_timestamp=1455616740, sentry_key=89dsa2, sentry_secret=897dsa'
        expect( ErrorStore::Auth.new(error).instance_variable_get(:@client) ).to eq(error.request.headers['HTTP_USER_AGENT'])
      end
      it 'assigns variables from auth_req' do
        auth_req = ErrorStore::Auth.new(error).parse_auth_header(error.request.headers['HTTP_X_SENTRY_AUTH'])
        expect( ErrorStore::Auth.new(error).instance_variable_get(:@client) ).to eq(auth_req['sentry_client'])
        expect( ErrorStore::Auth.new(error).instance_variable_get(:@version) ).to eq(auth_req['sentry_version'])
        expect( ErrorStore::Auth.new(error).instance_variable_get(:@app_secret) ).to eq(auth_req['sentry_secret'])
        expect( ErrorStore::Auth.new(error).instance_variable_get(:@app_key) ).to eq(auth_req['sentry_key'])
      end
      it 'assigns the CURRENT_VERSION if version not set' do
        error.request.headers['HTTP_X_SENTRY_AUTH'] = 'Sentry sentry_timestamp=1455616740, sentry_key=89dsa2, sentry_secret=897dsa'
        expect( ErrorStore::Auth.new(error).instance_variable_get(:@version) ).to eq(ErrorStore::CURRENT_VERSION)
      end
    end

    describe 'GET' do
      let(:params) { ErrorStore::Auth.new(error).parse_auth_header(error.request.headers['HTTP_X_SENTRY_AUTH']) }
      before { error.request.headers['REQUEST_METHOD'] = "GET" }
      before { error.request.parameters.merge!(params) }

      # TODO, add more when logic is added
      it 'raises MissingCredentials if auth_req is blank' do
        ##TODO HOWTO??
      end
      it 'sets sentry_client from HTTP_USER_AGENT if not set' do
        error.request.parameters.delete('sentry_client')
        expect( ErrorStore::Auth.new(error).instance_variable_get(:@client) ).to eq(error.request.headers['HTTP_USER_AGENT'])
      end
      it 'assigns variables from auth_req' do
        auth_req = ErrorStore::Auth.new(error).parse_auth_header(error.request.headers['HTTP_X_SENTRY_AUTH'])
        expect( ErrorStore::Auth.new(error).instance_variable_get(:@client) ).to eq(auth_req['sentry_client'])
        expect( ErrorStore::Auth.new(error).instance_variable_get(:@version) ).to eq(auth_req['sentry_version'])
        expect( ErrorStore::Auth.new(error).instance_variable_get(:@app_secret) ).to eq(auth_req['sentry_secret'])
        expect( ErrorStore::Auth.new(error).instance_variable_get(:@app_key) ).to eq(auth_req['sentry_key'])
      end
      it 'assigns the CURRENT_VERSION if version not set' do
        error.request.parameters.delete('sentry_version')
        expect( ErrorStore::Auth.new(error).instance_variable_get(:@version) ).to eq(ErrorStore::CURRENT_VERSION)
      end
    end
  end

  describe 'parse_auth_header' do
    it 'returns a hash with values from string' do
      expect( ErrorStore::Auth.new(error).parse_auth_header(error.request.headers['HTTP_X_SENTRY_AUTH']) ).to eq({"sentry_version"=>"'5'", "sentry_client"=>"'raven-ruby/0.15.2'", "sentry_timestamp"=>"1455616740", "sentry_key"=>"#{website.app_key}", "sentry_secret"=>"#{website.app_secret}"})
    end
  end

  describe '_error' do
    it 'returns the assigned error' do
      expect( ErrorStore::Auth.new(error).instance_variable_get(:@error) ).to eq(error)
    end
  end
end
