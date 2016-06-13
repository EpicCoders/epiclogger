require 'rails_helper'

RSpec.describe ErrorStore::Context do
  let(:website) { create :website }

  let(:post_request) { post_error_request(web_response_factory('ruby_exception'), website) }
  let(:get_request) { get_error_request(web_response_factory('js_exception'), website) }
  let(:post_error) { ErrorStore::Error.new(request: post_request) }
  let(:get_error) { ErrorStore::Error.new(request: get_request) }
  let(:post_context) { ErrorStore::Context.new(post_error) }
  let(:get_context) { ErrorStore::Context.new(get_error) }

  describe 'initialize' do
    it 'assigns error' do
      expect( get_context.instance_variable_get(:@error) ).to eq(get_error)
      expect( post_context.instance_variable_get(:@error) ).to eq(post_error)
    end
    it 'assigns agent' do
      expect( get_context.instance_variable_get(:@agent) ).to eq(get_error.request.headers['HTTP_USER_AGENT'])
      expect( post_context.instance_variable_get(:@agent) ).to eq(post_error.request.headers['HTTP_USER_AGENT'])
    end
    it 'assigns website_id' do
      expect( get_context.instance_variable_get(:@website_id) ).to eq(website.id.to_s)
      expect( post_context.instance_variable_get(:@website_id) ).to be_nil
    end
    it 'assigns ip_address' do
      expect( get_context.instance_variable_get(:@ip_address) ).to eq(get_error.request.headers['REMOTE_ADDR'])
      expect( post_context.instance_variable_get(:@ip_address) ).to eq(post_error.request.headers['REMOTE_ADDR'])
    end
    it 'assigns origin from http_origin' do
      expect( get_context.instance_variable_get(:@origin) ).to eq('http://192.168.2.3')
      expect( post_context.instance_variable_get(:@origin) ).to eq('http://192.168.2.3')
    end
    it 'assigns origin from http_referrer' do
      get_request.env.delete('HTTP_ORIGIN')
      get_request.env['HTTP_REFERER'] = 'waza referrer'
      expect( get_context.instance_variable_get(:@origin) ).to eq('waza referrer')

      post_request.env.delete('HTTP_ORIGIN')
      post_request.env['HTTP_REFERER'] = 'waza referrer'
      expect( post_context.instance_variable_get(:@origin) ).to eq('waza referrer')
    end
  end

  it 'responds to website' do
    expect( get_context ).to respond_to(:website)
    expect( post_context ).to respond_to(:website)
  end
  it 'responds to version' do
    expect( get_context ).to respond_to(:version)
    expect( post_context ).to respond_to(:version)
  end
end
