require 'rails_helper'

RSpec.describe ErrorsController, type: :controller do
  let(:user) { create :user }
  let(:website) { create :website }
  let!(:website_member) { create :website_member, website: website, user: user }
  let(:group) { create :grouped_issue, website: website }
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_error) { create :issue, subscriber: subscriber, group: group }
  let(:message) { 'asdada' }
  let(:default_params) { { format: :json } }

  describe 'POST #notify_subscribers' do
    context 'if logged in' do
      let(:params) { default_params.merge( message: message, id: group.id) }

      it 'should email subscribers' do
        params[:format] = 'js'
        mailer = double('UserMailer')
        expect(mailer).to receive(:deliver_later)
        expect(UserMailer).to receive(:notify_subscriber).with(group, user, message).and_return(mailer).once

        post_with user, :notify_subscribers, params
      end

      it 'should email 2 subscribers' do
        params[:format] = 'js'
        user2 = create :user, provider: "some"
        create :website_member, website: website, user_id: user2.id
        mailer = double('UserMailer')
        expect(mailer).to receive(:deliver_later).twice
        expect(UserMailer).to receive(:notify_subscriber).with(group, an_instance_of(User), message).and_return(mailer).twice
        post_with user, :notify_subscribers, params
      end

      it 'assigns message' do
        params[:format] = 'js'
        post_with user, :notify_subscribers, params
        expect(assigns(:message)).to eq('asdada')
      end
    end

    describe 'GET #index' do
      let(:params) { default_params.merge(current_issue: issue_error.id) }

      context 'if logged in' do

        it 'renders json' do
          get_with user, :index, params, { epiclogger_website_id: website.id}
          expect(response).to be_successful
          expect(response.content_type).to eq('application/json')
        end

        it 'assigns current_site errors' do
          get_with user, :index, params, { epiclogger_website_id: website.id}
          expect(assigns(:errors)).to eq([group])
        end
      end
    end
    context 'not logged in' do
      let(:params) { default_params.merge(current_issue: issue_error.id) }

      it 'should give error if not logged in' do
        get :index, params
        expect(response).to have_http_status(302)
      end
    end
  end

  describe 'GET #show' do
    let(:params) { default_params.merge(status: 'resolved', id: group.id, website_id: website.id) }
    render_views
    context 'if logged in' do

      it 'renders json' do
        get_with user, :show, params, { epiclogger_website_id: website.id}
        expect(response).to be_successful
        expect(response.content_type).to eq('application/json')
      end

      it 'renders the expected json' do
        get_with user, :show, params, { epiclogger_website_id: website.id}
        expect(response).to be_successful
        expect(response.body).to eq({
          id: website.id,
          app_secret: website.app_secret,
          app_key: website.app_key,
          domain: website.domain,
          title: website.title,
          platform: website.platform,
          new_event: website.new_event,
          frequent_event: website.frequent_event,
          daily: website.daily,
          realtime: website.realtime,
          owners: [
            {
              id: user.id,
              email: user.email,
              name: user.name,
              created_at: user.created_at,
              updated_at: user.updated_at,
              provider: user.provider,
              uid: user.uid,
              password_digest: user.password_digest,
              reset_password_token: user.reset_password_token,
              reset_password_sent_at: user.reset_password_sent_at,
              remember_created_at: user.remember_created_at,
              sign_in_count: user.sign_in_count,
              current_sign_in_at: user.current_sign_in_at,
              last_sign_in_at: user.last_sign_in_at,
              current_sign_in_ip: user.current_sign_in_ip,
              last_sign_in_ip: user.last_sign_in_ip,
              confirmation_token: user.confirmation_token,
              confirmed_at: user.confirmed_at,
              confirmation_sent_at: user.confirmation_sent_at,
              unconfirmed_email: user.unconfirmed_email,
              nickname: user.nickname,
              image: user.image,
              tokens: user.tokens
            }
          ]
        }.to_json)
      end
    end

    it 'should give error if not logged in' do
      get :show, params, { epiclogger_website_id: website.id}
      expect(response).to have_http_status(302)
    end
  end

  describe 'PUT #update' do
    let(:params) { default_params.merge(error: { status: 'resolved' }, id: group.id, website_id: website.id) }
    context 'if logged in' do
      it 'assigns error' do
        put_with user, :update, params, { epiclogger_website_id: website.id}
        expect(assigns(:error)).to eq(group)
      end
      it 'updates error status' do
        expect {
          put_with user, :update, params, { epiclogger_website_id: website.id}
          group.reload
        }.to change(group, :status).from('unresolved').to('resolved')
      end

      it 'does not allow update of other parameters other than status' do
        expect{
          put_with user, :update, id: group.id, error: { error: 'some' }, website_id: website.id, format: :json
        }.to_not change(group, :status).from('unresolved')
      end

      it 'renders json' do
        put_with user, :update, params, { epiclogger_website_id: website.id}
        expect(response).to be_successful
        expect(response.content_type).to eq('application/json')
      end
    end
    context 'not logged in' do
      let(:params) { default_params.merge(status: 'resolved', id: group.id, website_id: website.id) }
      it 'throws unauthorized' do
        get :update, params
        expect(response).to have_http_status(302)
      end
    end
  end

  describe 'PUT #resolve' do
    let(:params) { { id: group.id, format: :js } }
    context 'logged in' do
      it 'responds with js format' do
        params[:individual_resolve] = true
        put_with user, :resolve, params
        expect(response.content_type).to eq('text/javascript')
      end

      it 'resolves a single error' do
        new_error  = FactoryGirl.create(:grouped_issue, { website: website, checksum: SecureRandom.hex(), status: 'unresolved', resolved_at: nil } )
        params[:error_ids] = [new_error.id]
        put_with user, :resolve, params
        new_error.reload
        expect(new_error.status).to eq('resolved')
        expect(new_error.resolved_at).to be_truthy
      end

      it 'unresolves a single error' do
        new_error  = FactoryGirl.create(:grouped_issue, { website: website, checksum: SecureRandom.hex(), status: 'resolved', resolved_at: DateTime.now } )
        params[:error_ids] = [new_error.id]
        put_with user, :unresolve, params
        new_error.reload
        expect(new_error.status).to eq('unresolved')
        expect(new_error.resolved_at).to eq(nil)
      end

      it 'resolves multiple errors' do
        new_error1  = FactoryGirl.create(:grouped_issue, { website: website, checksum: SecureRandom.hex(), status: 'unresolved', resolved_at: nil } )
        new_error2  = FactoryGirl.create(:grouped_issue, { website: website, checksum: SecureRandom.hex(), status: 'unresolved', resolved_at: nil } )
        params[:error_ids] = [new_error1.id, new_error2.id]
        put_with user, :resolve, params
        new_error1.reload
        new_error2.reload
        expect([new_error1.status, new_error2.status]).to all(eq('resolved'))
        expect([new_error1.resolved_at, new_error2.resolved_at]).to all(be_truthy)
      end

      it 'unresolves multiple errors' do
        new_error1  = FactoryGirl.create(:grouped_issue, { website: website, checksum: SecureRandom.hex(), status: 'resolved', resolved_at: DateTime.now } )
        new_error2  = FactoryGirl.create(:grouped_issue, { website: website, checksum: SecureRandom.hex(), status: 'resolved', resolved_at: DateTime.now } )
        params[:error_ids] = [new_error1.id, new_error2.id]
        put_with user, :unresolve, params
        new_error1.reload
        new_error2.reload
        expect([new_error1.status, new_error2.status]).to all(eq('unresolved'))
        expect([new_error1.resolved_at, new_error2.resolved_at]).to all(be_nil)
      end
    end
  end

  describe "private methods" do
    let(:params) { default_params.merge(id: group.id, website_id: website.id, current_tab: 'aggregations') }

    context "resolve_issues" do
      let(:controller) { ErrorsController.new }
      let(:errors) do
        array = []
        number_of_errors = 20
        number_of_errors.times do |index|
          new_error = FactoryGirl.create(:grouped_issue, { website: website, checksum: SecureRandom.hex(), status: 'unresolved', resolved_at: nil } )
          array.push(new_error)
        end
        array.sort_by!(&:last_seen).reverse!
      end

      it "returns the next issues in the list and updates pagination" do
        ids = errors.first(5).map(&:id)
        resolve = true
        errors_per_page = 5
        page = 1
        current_error = errors.first.id
        controller.instance_eval { resolve_issues(ids, resolve, errors_per_page, page, current_error) }
        # remove the first 5 since their status was updated
        sidebar = controller.instance_eval { @sidebar }
        expect(sidebar).to match_array(errors[errors_per_page..errors_per_page + 4])

        pagination = controller.instance_eval { @pagination }
        # start_value - end_value of total_count
        # eg: 5 - 10 of 15
        start_value = pagination.offset_value + 1
        end_value = pagination.last_page? ? pagination.total_count : pagination.offset_value + pagination.limit_value
        expect(start_value).to eq(1)
        expect(end_value).to eq(errors_per_page)
      end
    end
  end
end
