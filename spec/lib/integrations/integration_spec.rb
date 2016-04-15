require 'rails_helper'

RSpec.describe Integrations::Integration do
  let(:website) { create :website }
  let(:integration) { create :integration, website: website }
  let(:driver) { Integrations.get_driver(integration.provider.to_sym) }
  let(:new_integration) { Integrations::Integration.new(integration, driver) }
  let(:time_now) { Time.parse('2016-02-10') }

  it { expect(new_integration.name).to eq('Intercom') }
  it { expect(new_integration.type).to eq(:intercom) }

  describe 'initialize' do
    it 'assigns request and issue provided' do
      expect( new_integration.instance_variable_get(:@integration) ).to eq(integration)
      expect( new_integration.instance_variable_get(:@driver) ).to be_kind_of(Integrations::Drivers::Intercom)
    end
  end
end
