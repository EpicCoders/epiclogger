require 'rails_helper'

describe Integration do
  let(:user) { create :user }
  let(:website) { create :website }
  let(:integration) { create :integration, website: website }

  it 'has a valid factory' do
    expect(build(:integration, website: nil)).to be_valid
  end

  it 'belongs to website' do
    expect(integration).to belong_to(:website)
  end

  it 'should have a name' do
    expect(subject).to validate_presence_of(:name)
  end

  it 'should have a provider' do
    expect(subject).to validate_presence_of(:provider)
  end

  describe 'driver' do
    it 'should create a new instance of the Integrations module' do
      expect( Integrations).to receive(:create).with(integration)
      integration.driver
    end
  end

  describe 'select_application' do
    it 'should save the selected application into the configuration hash' do
      integration.update_attributes(application: 'my_app')
      expect(integration.configuration['selected_application']).to eq('my_app')
    end
  end

  describe 'assign_configuration' do
    let(:auth_hash) { {
                    'provider' => 'github',
                    'uid' => '12345',
                    'info' => {
                      'name' => 'natasha',
                      'email' => 'hi@natashatherobot.com',
                      'nickname' => 'NatashaTheRobot'
                      },
                    'credentials' => {
                      'token' => '445da8f3214dafaaffb11f9f71c2ed8612287ac8',
                      'expires' => false
                      },
                    'extra' => {
                      'raw_info' => {
                        'login' => 'natasha'
                        }
                      }
                    } }

    it 'should save the configuration and provider' do
      new_integration =  FactoryGirl.create( :integration, { configuration: nil } )
      new_integration.assign_configuration(auth_hash)
      expect(new_integration.configuration).to_not be_nil
    end
  end

  describe 'get_applications' do
    it 'should call the applications method in the driver' do
      expect_any_instance_of(Integrations::Drivers::Github).to receive(:applications)
      integration.get_applications
    end
  end

  describe 'selected_application' do
    it 'should call selected_application method in the driver' do
      expect_any_instance_of(Integrations::Drivers::Github).to receive(:selected_application)
      integration.selected_application
    end
  end
end
