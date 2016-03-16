require 'rails_helper'

RSpec.describe ErrorStore::Interfaces::User do
  let(:website) { create :website }
  let(:post_request) { post_error_request(website.app_key, website.app_secret, web_response_factory('ruby_exception')) }
  let(:get_request) { get_error_request(website.app_key, web_response_factory('js_exception')) }
  let(:post_data) { validated_request(post_request)[:interfaces][:user] }
  let(:user) { ErrorStore::Interfaces::User.new(post_data) }

  it 'it returns User for display_name' do
    expect( ErrorStore::Interfaces::User.display_name ).to eq("User")
  end
  it 'it returns type :user' do
    expect( user.type ).to eq(:user)
  end

  describe 'sanitize_data' do
    before{ post_data.merge!({:username=>'Cristi', :ip_address=>'192.168.1.50'}) }
    it 'trims data[:id] to max_size of 128' do
      post_data[:id] = '24183913'*20
      user.sanitize_data(post_data)
      expect( user._data[:id].length ).to eq(128)
    end
    it 'raises ValidationError if data[:email] is invalid' do
      post_data[:email] = 'email.co'
      expect{ user.sanitize_data(post_data) }.to raise_exception(ErrorStore::ValidationError)
    end
    it 'trims the email to max_size of 128 if it is too big' do
      post_data[:email] = ('cristi' * 30) + '@email.com'
      user.sanitize_data(post_data)
      expect( user._data[:email].length ).to eq(128)
    end
    it 'trims the username to max_size 128' do
      post_data[:username] = ('baCristi' * 20)
      user.sanitize_data(post_data)
      expect( user._data[:username].length ).to eq(128)
    end
    it 'raises ValidationError if ip is not valid' do
      post_data[:ip_address] = '1.1.1.1.1.1.1'
      expect{ user.sanitize_data(post_data) }.to raise_exception(ErrorStore::ValidationError)
    end
    it 'assigns the right _data attributes' do
      user.sanitize_data(post_data)
      post_data.merge!({:data=>{}})
      expect( user._data ).to eq(post_data)
    end
    it 'returns User instance' do
      expect( user.kind_of?(ErrorStore::Interfaces::User) ).to be(true)
    end
  end

  describe 'get_hash' do
    it 'empty array' do
      expect( user.get_hash ).to eq([])
    end
  end
end
