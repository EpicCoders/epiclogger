require 'rails_helper'

RSpec.describe Integrations do
  let(:website) { create :website }
  let(:subscriber) { create :subscriber, website: website }
  let(:integration) { create :integration, website: website }

  describe 'create', truncation: true do
    it 'calls new on integration' do
      expect(Integrations::Integration).to receive(:new)
      subject.create(integration)
    end
    it 'returns an instance of integraiton' do
      expect(subject.create(integration)).to be_kind_of(Integrations::Integration)
    end
  end

  describe 'find_drivers' do
    it 'contains all the drivers in the folder' do
      expect(subject.available_drivers.length).to eq(2)
    end

    it 'throws error if file could not be loaded' do
      path = "lib/integrations/drivers/testing.rb"
      content = "1/0"
      File.open(path, "w+") do |f|
        f.write(content)
      end
      expect(Rails.logger).to receive(:error).with("Could not load class testing")
      subject.find_drivers
      subject.available_drivers.delete_at(1)
      subject.available_drivers.delete_at(2)
      File.delete("lib/integrations/drivers/testing.rb")
    end
  end

  describe 'available_drivers' do
    it 'retuns assigns the drivers_list' do
      expect(subject.available_drivers).to eq(subject.class_variable_get(:@@drivers_list))
    end

    it 'returns the drivers array' do
      expect(subject.available_drivers).to be_kind_of(Array)
    end

    it 'gives the drivers with all of them if find_drivers called' do
      expect(subject.available_drivers).to be_kind_of(Array)
      expect(subject.available_drivers.length).to eq(2)
      expect(subject.available_drivers).to eq(subject.class_variable_get(:@@drivers_list))
    end
  end

  describe 'drivers_types' do
    it 'returns an array of drivers types' do
      subject.class_variable_set(:@@drivers_list, []) # reset the drivers list
      subject.find_drivers

      expect(subject.drivers_types).to eq([:github, :intercom])
    end
  end

  describe 'get_driver' do
    it 'raises Integrations::InvalidDriver if not found' do
      expect { subject.get_driver(:random) }.to raise_exception(Integrations::InvalidDriver)
    end

    it 'returns the driver' do
      expect(subject.get_driver(:intercom)).to eq(Integrations::Drivers::Intercom)
    end
  end

  describe 'config' do
    it 'returns hash with configurations' do
      expect( subject.config ).to be_kind_of(Hash)
    end

    it 'contains github app keys' do
      expect( subject.config ).to include(:github)
    end

    it 'contains intercom app keys' do
      expect( subject.config ).to include(:intercom)
    end
  end

  describe 'exceptions' do
    it 'has IntegrationError exception' do
      expect { raise Integrations::IntegrationError }.to raise_error(Integrations::IntegrationError)
    end
    it 'has all the other exceptions' do
      expect { raise Integrations::WebsiteMissing }.to raise_error(Integrations::WebsiteMissing)
      expect { raise Integrations::InvalidDriver }.to raise_error(Integrations::InvalidDriver)
      expect { raise Integrations::ValidationError }.to raise_error(Integrations::ValidationError)
    end
  end
end
