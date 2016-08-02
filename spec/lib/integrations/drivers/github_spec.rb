require 'rails_helper'

RSpec.describe Integrations::Drivers::Intercom do
  let(:website) { create :website }
  let(:integration) { create :integration, website: website, provider: :github }
  let(:driver) { Integrations.get_driver(integration.provider.to_sym) }
  let(:integration_driver) { driver.new(Integrations::Integration.new(integration, driver)) }
  let(:time_now) { Time.parse('2016-02-10') }

  describe 'name' do
    it 'returns the driver name' do
      expect(integration_driver.name).to eq('Github')
    end
  end

  describe 'type' do
    it 'returns the driver type' do
      expect(integration_driver.type).to eq(:github)
    end
  end

  describe 'api_url' do
    it 'return github api url' do
      expect(integration_driver.api_url).to eq('https://api.github.com/')
    end
  end

  describe 'selected_application' do
    it 'returns the selected app in the config' do
      expect(integration.selected_application).to eq(integration.configuration['selected_application'])
    end
  end

  describe 'auth_type' do
    it 'returns auth_type' do
      expect(integration_driver.auth_type).to eq(:oauth)
    end
  end

  describe 'applications' do
    it 'returns an empty array if you dont own any app or dont belong to any organization that owns apps' do
      stub_request(:get, "https://api.github.com/user/repos?affiliation=owner,organization_member").
        with(:headers => {'Authorization'=>'token'}).
        to_return(:status => 200, :body => web_response_factory('github/github_forked_apps'), :headers => {})
      expect(integration_driver.applications).to eq({ "Owner": [] })
    end

    it 'returns apps that belong to you or an organization you are part of' do
      stub_request(:get, "https://api.github.com/user/repos?affiliation=owner,organization_member").
        with(:headers => {'Authorization'=>'token'}).
        to_return(:status => 200, :body => web_response_factory('github/github_apps'), :headers => {})
      expect(integration_driver.applications).to eq({:Owner=>["test-repo"],
 "Elevenblack"=>["deals-tablebookings", "Pindinn", "rai-mobile", "rai-wp", "TableBookings", "tablebookings-mobile", "TableBookings_Widget"],
 "EpicCoders"=>["epicghost", "epiclogger", "epiclogger-js", "kirki"]})
    end
  end

  describe 'create_task' do
    it 'returns successfull response' do
      stub_request(:post, integration_driver.api_url + 'repos/' + integration.configuration["username"].to_s + '/' + integration.configuration["selected_application"].to_s + '/issues')
        .with(:body => {"title" => "test"}.to_json,
        :headers => {'Accept'=>'application/json', 'Accept-Encoding'=>'gzip, deflate', 'Authorization'=>'token', 'Content-Type'=>'application/json'} )
        .to_return(status: 200, body: web_response_factory('github/github_task'))
      expect(integration.driver.create_task('test')).to_not be_nil
    end
  end
end
