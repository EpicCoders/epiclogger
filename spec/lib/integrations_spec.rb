require 'rails_helper'

RSpec.describe Integrations do
  let(:website) { create :website }
  let(:subscriber) { create :subscriber, website: website }
  let(:interface) { create :interface, website: website }

  # describe 'create', truncation: true do
  #   it 'calls error.create!' do
  #     expect_any_instance_of(ErrorStore::Error).to receive(:create!)
  #     subject.create!(request)
  #   end
  #   it 'returns the error id' do
  #     event_id = subject.create!(request)
  #     expect(event_id).to be_kind_of(String)
  #     expect(event_id.length).to eq(32)
  #   end
  # end

  describe 'find_drivers' do
    it 'contains all the drivers in the folder' do
      expect(subject.available_drivers.length).to eq(1)
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
      expect(subject.available_drivers.length).to eq(1)
      expect(subject.available_drivers).to eq(subject.class_variable_get(:@@drivers_list))
    end
  end

  describe 'drivers_types' do
    it 'returns an array of drivers types' do
      subject.class_variable_set(:@@drivers_list, []) # reset the drivers list
      subject.find_drivers

      expect(subject.drivers_types).to eq([:intercom])
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
