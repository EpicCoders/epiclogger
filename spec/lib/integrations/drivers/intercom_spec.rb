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
end
