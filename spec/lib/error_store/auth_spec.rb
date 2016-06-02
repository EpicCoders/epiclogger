require 'rails_helper'

RSpec.describe ErrorStore::Auth do
  let(:user) { create :user }
  let(:website) { create :website }
  let!(:website_member) { create :website_member, user: user, website: website }
  let(:group) { create :grouped_issue, website: website }
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_error) { create :issue, subscriber: subscriber, group: group, event_id: '8af060b2986f5914764d49b7f39b036c' }

  let(:post_request) { post_error_request(web_response_factory('ruby_exception'), website) }
  let(:get_request) { get_error_request(web_response_factory('js_exception'), website) }
  let(:post_error) { ErrorStore::Error.new(request: post_request) }
  let(:get_error) { ErrorStore::Error.new(request: get_request) }
  let(:post_auth) { ErrorStore::Auth.new(post_error) }
  let(:get_auth) { ErrorStore::Auth.new(get_error) }

  describe 'initialize' do
    it 'assigns error' do
      expect( post_auth.instance_variable_get(:@error) ).to eq(post_error)
    end
    it 'calls get_authorization' do
      expect_any_instance_of(ErrorStore::Auth).to receive(:get_authorization)
      post_auth
    end
  end

  describe 'get_authorization' do
    describe 'POST' do
      subject { post_auth }
      it 'raises MissingCredentials if HTTP_X_SENTRY_AUTH or HTTP_AUTHORIZATION are missing' do
        post_error.request.env.delete 'HTTP_X_SENTRY_AUTH'
        post_error.request.env.delete 'HTTP_AUTHORIZATION'
        expect { subject }.to raise_exception(ErrorStore::MissingCredentials, 'Missing authentication header')
      end

      it 'checks HTTP_X_SENTRY_AUTH for Sentry string and returns parsed' do
        subject
        expect( subject.instance_variable_get(:@client) ).to eq('raven-ruby/0.15.2')
        expect( subject.instance_variable_get(:@version) ).to eq('5')
        expect( subject.instance_variable_get(:@app_key) ).to eq(website.app_key)
        expect( subject.instance_variable_get(:@app_secret) ).to eq(website.app_secret)
      end

      it 'checks HTTP_AUTHORIZATION for Sentry string and returns parsed' do
        post_error.request.headers['HTTP_AUTHORIZATION'] = post_error.request.headers['HTTP_X_SENTRY_AUTH']
        post_error.request.headers['HTTP_X_SENTRY_AUTH'] = ''
        subject
        expect( subject.instance_variable_get(:@client) ).to eq('raven-ruby/0.15.2')
        expect( subject.instance_variable_get(:@version) ).to eq('5')
        expect( subject.instance_variable_get(:@app_key) ).to eq(website.app_key)
        expect( subject.instance_variable_get(:@app_secret) ).to eq(website.app_secret)
      end
      it 'raises MissingCredentials if auth_req is blank' do
        post_error.request.headers['HTTP_AUTHORIZATION'] = ''
        post_error.request.env.delete 'HTTP_X_SENTRY_AUTH'
        expect { subject }.to raise_exception(ErrorStore::MissingCredentials, 'Missing authentication information')
      end

      it 'sets sentry_client from HTTP_USER_AGENT if not set' do
        post_error.request.headers['HTTP_X_SENTRY_AUTH'] = 'Sentry sentry_version=5,sentry_timestamp=1455616740, sentry_key=89dsa2, sentry_secret=897dsa'
        expect( subject.instance_variable_get(:@client) ).to eq(post_error.request.headers['HTTP_USER_AGENT'])
      end
      it 'assigns variables from auth_req' do
        auth_req = subject.parse_auth_header(post_error.request.headers['HTTP_X_SENTRY_AUTH'])
        expect( subject.instance_variable_get(:@client) ).to eq(auth_req['sentry_client'])
        expect( subject.instance_variable_get(:@version) ).to eq(auth_req['sentry_version'])
        expect( subject.instance_variable_get(:@app_secret) ).to eq(auth_req['sentry_secret'])
        expect( subject.instance_variable_get(:@app_key) ).to eq(auth_req['sentry_key'])
      end
      it 'assigns the CURRENT_VERSION if version not set' do
        post_error.request.headers['HTTP_X_SENTRY_AUTH'] = 'Sentry sentry_timestamp=1455616740, sentry_key=89dsa2, sentry_secret=897dsa'
        expect( subject.instance_variable_get(:@version) ).to eq(ErrorStore::CURRENT_VERSION)
      end
    end

    describe 'GET' do
      subject { get_auth }

      it 'raises MissingCredentials if auth_req is blank' do
        get_error.request.params.delete_if { true }
        expect{ subject }.to raise_exception(ErrorStore::MissingCredentials, 'Missing authentication information')
      end
      it 'sets sentry_client from HTTP_USER_AGENT if not set' do
        get_error.request.params.delete('sentry_client')
        expect( subject.instance_variable_get(:@client) ).to eq(get_error.request.headers['HTTP_USER_AGENT'])
      end
      it 'assigns variables from auth_req' do
        expect( subject.instance_variable_get(:@client) ).to eq('raven-js/1.1.20')
        expect( subject.instance_variable_get(:@version) ).to eq('4')
        expect( subject.instance_variable_get(:@app_secret) ).to be_nil
        expect( subject.instance_variable_get(:@app_key) ).to eq(website.app_key)
      end
      it 'assigns the CURRENT_VERSION if version not set' do
        get_error.request.params.delete('sentry_version')
        expect( subject.instance_variable_get(:@version) ).to eq(ErrorStore::CURRENT_VERSION)
      end
    end
  end

  describe 'parse_auth_header' do
    it 'returns a hash with values from string' do
      expect( post_auth.parse_auth_header(post_error.request.headers['HTTP_X_SENTRY_AUTH']) ).to eq(
        'sentry_version' => '5',
        'sentry_client' => 'raven-ruby/0.15.2',
        'sentry_timestamp' => '1455616740',
        'sentry_key' => website.app_key,
        'sentry_secret' => website.app_secret
      )
    end
  end

  describe '_error' do
    it 'returns the assigned error' do
      expect( post_auth.instance_variable_get(:@error) ).to eq(post_error)
      expect( get_auth.instance_variable_get(:@error) ).to eq(get_error)
    end
  end
end
