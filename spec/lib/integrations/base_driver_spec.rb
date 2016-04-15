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
      expect(integration_driver.name).to eq('Intercom')
    end
  end
end
