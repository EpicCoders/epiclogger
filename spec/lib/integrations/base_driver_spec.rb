require 'rails_helper'

RSpec.describe Integrations::BaseDriver do
  let(:website) { create :website }
  let(:integration) { create :integration, website: website }
  let(:driver) { Integrations.get_driver(integration.provider.to_sym) }
  let(:integration_driver) { driver.new(Integrations::Integration.new(integration, driver)) }
  let(:time_now) { Time.parse('2016-02-10') }

  describe 'initialize' do
    it 'assigns integration provided' do
      expect( Integrations::BaseDriver.new(integration).instance_variable_get(:@integration) ).to eq(integration)
    end
  end

  describe 'name' do
    it 'returns the driver name' do
      expect(integration_driver.name).to eq('Github')
    end
  end

  describe 'type' do
    it "returns the driver type" do
      expect(integration_driver).to receive(:type)
      integration_driver.type
    end
  end

  describe "config" do
    it "returns the contents of integrations.yml" do
      expect(integration_driver.config).to eq(YAML.load(ERB.new(File.read("#{Rails.root}/config/integrations.yml")).result).with_indifferent_access[integration_driver.type.to_s])
    end
  end

  describe 'applications' do
    it "calls the applications method in the driver" do
      expect(integration_driver).to receive(:applications)
      integration_driver.applications
    end
  end

  describe 'selected_applications' do
    it 'calls the selected_application method in the driver' do
      expect(integration_driver).to receive(:selected_application)
      integration_driver.selected_application
    end
  end

  describe "configuration" do
    it "returns the configuration of the integration" do
      expect(integration_driver.configuration).to eq(integration.configuration)
    end
  end

  describe "build_configuration" do
    let(:auth_hash) { { 'provider' => 'github',
                      'uid' => '12345',
                      'info' => {
                      'name' => 'natasha',
                      'email' => 'hi@natashatherobot.com',
                      'nickname' => 'NatashaTheRobot'
                    },
                    'credentials' =>
                      {
                        'token' => '445da8f3214dafaaffb11f9f71c2ed8612287ac8',
                        'expires' => false
                      },

                    'extra' =>
                      {
                        'raw_info' => {
                          'login' => 'natasha'
                        }
                      }
                    } }
    it "builds the config hash" do
      config = integration_driver.build_configuration(auth_hash)
      expect(config).to eq( {
          token: auth_hash['credentials']['token'],
          username: auth_hash['extra']['raw_info']['login'],
          provider: auth_hash['provider'],
          secret: nil,
          refresh_token: nil,
          token_expires_at: nil,
          token_expires: false,
          uid: auth_hash['uid']
        } )
    end
  end
end
