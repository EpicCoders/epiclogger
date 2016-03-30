require 'rails_helper'

RSpec.describe ErrorsController, type: :controller do
  let(:user) { create :user }
  let(:website) { create :website }
  let!(:website_member) { create :website_member, website: website, user: user }
  let(:group) { create :grouped_issue, website: website }
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_error) { create :issue, subscriber: subscriber, group: group }
  let(:message) { 'asdada' }
  let(:default_params) { { epiclogger_website_id: website.id, format: :json } }

  describe 'POST #notify_subscribers' do
    context 'if logged in' do
      include Warden::Test::Helpers
      after { Warden.test_reset! }

      before { login_as(user) }
      let(:params) { default_params.merge(user: {password: 'hello123', email: user.email}, message: message, id: group.id) }

      it 'should email subscribers' do
        mailer = double('UserMailer')
        expect(mailer).to receive(:deliver_later)
        expect(UserMailer).to receive(:notify_subscriber).with(group, user, message).and_return(mailer).once

        post :notify_subscribers, params
      end

      it 'should email 2 subscribers' do
        user2 = create :user
        create :website_member, website: website, user_id: user2.id
        mailer = double('UserMailer')
        expect(mailer).to receive(:deliver_later).twice
        expect(UserMailer).to receive(:notify_subscriber).with(group, an_instance_of(Member), message).and_return(mailer).twice
        post :notify_subscribers, params
      end

      it 'assigns message' do
        post :notify_subscribers, params
        expect(assigns(:message)).to eq('asdada')
      end
    end

    describe 'GET #index' do
      let(:params) { default_params.merge(website_id: website.id) }

      context 'if logged in' do
        before { auth_user(user) }

        it 'renders json' do
          get :index, params
          expect(response).to be_successful
          expect(response.content_type).to eq('application/json')
        end

        it 'assigns current_site errors' do
          auth_user(user)
          get :index, params
          expect(assigns(:errors)).to eq([group])
        end
      end

      it 'should give error if not logged in' do
        get :index, params
        expect(response.body).to eq({errors: ['Authorized users only.']}.to_json)
        expect(response).to have_http_status(401)
      end
    end
    context 'not logged in' do
      let(:params) { default_params.merge({website_id: website.id}) }
      it 'should give error if not logged in' do
        get :index, params
        expect(response.body).to eq({errors: ['Authorized users only.']}.to_json)
        expect(response).to have_http_status(401)
      end
    end
  end

  describe 'GET #show' do
    let(:params) { default_params.merge(status: 'resolved', id: group.id, website_id: website.id) }
    render_views
    context 'if logged in' do
      before { auth_user(user) }

      it 'renders json' do
        get :show, params
        expect(response).to be_successful
        expect(response.content_type).to eq('application/json')
      end

      it 'renders the expected json' do
        get :show, params
        expect(response).to be_successful
        expect(response.body).to eq({
          id: group.id,
          message: group.message,
          culprit: group.culprit,
          times_seen: group.times_seen,
          first_seen: group.first_seen,
          last_seen: group.last_seen,
          score: group.score,
          status: group.status,
          level: group.level,
          issue_logger: group.issue_logger,
          resolved_at: group.resolved_at,
          subscribers: [
            {
              id: subscriber.id,
              email: subscriber.email,
              avatar_url: "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(subscriber.email)}"
            }
          ],
          subscribers_count: group.subscribers.count,
          issues: [
            {
              id: issue_error.id,
              platform: issue_error.platform,
              event_id: issue_error.event_id,
              data: issue_error.error.data,
              message: issue_error.message,
              datetime: issue_error.datetime,
              time_spent: issue_error.time_spent,
            }
          ]
        }.to_json)
      end
    end

    it 'should give error if not logged in' do
      get :show, params
      expect(response.body).to eq({ errors: ['Authorized users only.'] }.to_json)
      expect(response).to have_http_status(401)
    end
  end

  describe 'PUT #update' do
    let(:params) { default_params.merge(error: { status: 'resolved' }, id: group.id, website_id: website.id) }
    context 'if logged in' do
      before { auth_user(user) }
      it 'assigns error' do
        put :update, params
        expect(assigns(:error)).to eq(group)
      end
      it 'updates error status' do
        expect {
          put :update, params
          group.reload
        }.to change(group, :status).from('unresolved').to('resolved')
      end

      it 'does not allow update of other parameters other than status' do
        expect{
          put :update, id: group.id, error: { error: 'some' }, website_id: website.id, format: :json
        }.to_not change(group, :status).from('unresolved')
      end

      it 'renders json' do
        put :update, params
        expect(response).to be_successful
        expect(response.content_type).to eq('application/json')
      end
    end
    context 'not logged in' do
      let(:params) { default_params.merge(status: 'resolved', id: group.id, website_id: website.id) }
      it 'throws unauthorized' do
        get :update, params
        expect(response.body).to eq({ errors: ['Authorized users only.'] }.to_json)
        expect(response).to have_http_status(401)
      end
    end

  end
end
