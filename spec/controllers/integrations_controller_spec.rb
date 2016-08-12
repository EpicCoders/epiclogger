require 'rails_helper'

RSpec.describe IntegrationsController, type: :controller do
  let(:user) { create :user }
  let(:website) { create :website }
  let!(:website_member) { create :website_member, website: website, user: user }
  let!(:integration) { create :integration, website: website, provider: :github }
  let(:default_params) { { id: integration.id } }
  before(:each) do session[:epiclogger_website_id] = website.id end

  describe 'PUT#update' do
    let(:params) { default_params.merge(integration: { app_name: 'gogu', app_owner: 'ion' } ) }
    it 'updates the integration' do
      expect {
        put_with user, :update, params
        integration.reload
      }.to change { integration.configuration['selected_application'] }.from('test').to('gogu')
      .and change { integration.configuration['application_owner'] }.from(nil).to('ion')
    end

    it 'redirects to settings_path with success message' do
      put_with user, :update, params
      expect(response).to redirect_to(settings_path(main_tab: 'integrations', integration_tab: integration.provider))
      expect(flash[:notice]).to eq('Integration updated!')
    end
  end

  describe 'DELETE#destroy' do
    it 'destroys the integration' do
      expect{
        delete_with user, :destroy, default_params
      }.to change(Integration, :count).by(-1)
    end

    it 'redirects to settings_path with message' do
      delete_with user, :destroy, default_params
      expect(response).to redirect_to(settings_path(main_tab: 'integrations', integration_tab: integration.provider))
      expect(flash[:notice]).to eq('Integration deleted!')
    end
  end

  describe 'POST#create_task' do
    let(:driver) { Integrations.get_driver(integration.provider.to_sym) }
    let(:integration_driver) { driver.new(Integrations::Integration.new(integration, driver)) }
    let(:group) { create :grouped_issue, website: website }
    let(:params) { default_params.merge( title: 'test', error_id: group.id ) }
    context 'success' do

      before(:each) do
        stub_request(:post, integration_driver.api_url + 'repos/' + integration.configuration["username"].to_s + '/' + integration.configuration["selected_application"].to_s + '/issues')
        .with(:body => {"title" => "test"}.to_json,
        :headers => {'Authorization'=>'token'} )
        .to_return(status: 200, body: web_response_factory('github/github_task'))
      end

      it 'creates a new task' do
        expect_any_instance_of(Integrations::Drivers::Github).to receive(:create_task)
        post_with user, :create_task, params
      end

      it 'redirects error_path with response' do
        post_with user, :create_task, params
        expect(response).to redirect_to(error_path(params[:error_id], task: JSON.parse(web_response_factory('github/github_task'))))
      end
    end

    context 'failure' do
      it 'redirects to error path with error message' do
        stub_request(:post, integration_driver.api_url + 'repos/' + integration.configuration["username"].to_s + '/' + integration.configuration["selected_application"].to_s + '/issues')
        .with(:body => {"title" => "test"}.to_json,
        :headers => {'Authorization'=>'token'} )
        .to_return(status: 500, body: '')
        post_with user, :create_task, params
        expect(response).to redirect_to(error_path(params[:error_id], task: nil))
        expect(flash[:error]).to eq("Operation failed!")
      end
    end
  end
end