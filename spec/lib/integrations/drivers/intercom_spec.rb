require 'rails_helper'

RSpec.describe Integrations::Drivers::Intercom do
  let(:website) { create :website }
  let(:integration) { create :integration, website: website, provider: :intercom }
  let(:driver) { Integrations.get_driver(integration.provider.to_sym) }
  let(:integration_driver) { driver.new(Integrations::Integration.new(integration, driver)) }
  let(:time_now) { Time.parse('2016-02-10') }

  describe 'name' do
    it 'returns the driver name' do
      expect(integration_driver.name).to eq('Intercom')
    end
  end

  describe 'type' do
    it 'returns the driver type' do
      expect(integration_driver.type).to eq(:intercom)
    end
  end

  describe 'api operations' do
    let(:intercom_users) { [ { email: "hyperionel@yahoo.com", avatar: nil},
                             { email: "bogdan_hyperion@yahoo.com", avatar: nil},
                             { email: "ungureanu.bogdan.sorin@gmail.com", avatar: nil} ] }
    context 'list_subscribers' do
      it 'returns the user list of your intercom app' do
        stub_request(:get, integration_driver.api_url + 'users').
          with(:headers => {'Authorization'=>'Basic Og=='}).
          to_return(:status => 200, :body => web_response_factory('intercom/intercom_users'), :headers => {})
        expect(integration_driver.list_subscribers).to eq(intercom_users)
      end
    end

    context 'send_mesage' do
      let(:message_users) { [ { "email"=>"ungureanu.bogdan.sorin@gmail.com", :avatar=>nil } ] }
      it 'sends message to intercom users' do
        stub_request(:post, "https://api.intercom.io/messages").
         with(:body => "{\"message_type\":\"inapp\",\"body\":\"test\",\"template\":\"plain\",\"from\":{\"type\":\"admin\",\"id\":\"12345\"},\"to\":{\"type\":\"user\",\"email\":\"ungureanu.bogdan.sorin@gmail.com\"}}",
              :headers => {'Authorization'=>'Basic Og=='}).
         to_return(:status => 200, :body => web_response_factory('intercom/intercom_post_message'), :headers => {})
        expect(integration_driver.send_message(message_users, 'test').any? { |response|  response['owner']['email'] == message_users.first['email'] } ).to be true
      end
    end
  end

  describe 'api_url' do
    it 'returns the intercom api_url' do
      expect(integration_driver.api_url).to eq('https://api.intercom.io/')
    end
  end

  describe 'auth_type' do
    it 'returns auth_type' do
      expect(integration_driver.auth_type).to eq(:oauth)
    end
  end
end
