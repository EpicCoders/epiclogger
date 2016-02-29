require 'rails_helper'

RSpec.describe ErrorStore::Context do
  let(:website) { create :website }
  let(:group) { create :grouped_issue, website: website }
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_error) { create :issue, subscriber: subscriber, group: group, event_id: '8af060b2986f5914764d49b7f39b036c' }
  let(:error) { ErrorStore::Error.new(request: ActionDispatch::Request.new('REQUEST_METHOD' => 'POST','HTTP_USER_AGENT'=>'Faraday v0.9.2','REMOTE_ADDR'=>'127.0.0.1','HTTP_X_SENTRY_AUTH' => "Sentry sentry_version='5', sentry_client='raven-ruby/0.15.2',sentry_timestamp=1455616740, sentry_key=#{website.app_key}, sentry_secret=#{website.app_secret}",'HTTP_ACCEPT_ENCOaDING' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3','rack.input' => StringIO.new(Base64.strict_encode64(Zlib::Deflate.deflate(issue_error.data))))) }

  before { error.request.parameters.merge!("format"=>:json, "controller"=>"api/v1/store", "action"=>"create", "id"=>"1") }

  describe 'initialize' do
    it 'assigns error' do
      expect( ErrorStore::Context.new(error).instance_variable_get(:@error) ).to eq(error)
    end
    it 'assigns agent' do
      expect( ErrorStore::Context.new(error).instance_variable_get(:@agent) ).to eq(error.request.headers['HTTP_USER_AGENT'])
    end
    it 'assigns website_id' do
      expect( ErrorStore::Context.new(error).instance_variable_get(:@website_id) ).to eq(error.request.parameters['id'])
    end
    it 'assigns ip_address' do
      expect( ErrorStore::Context.new(error).instance_variable_get(:@ip_address) ).to eq(error.request.headers['REMOTE_ADDR'])
    end
  end

  it 'responds to website' do
    expect( ErrorStore::Context.new(error).website ).to be_nil
  end
  it 'responds to version' do
    expect( ErrorStore::Context.new(error).version ).to be_nil
  end
end
