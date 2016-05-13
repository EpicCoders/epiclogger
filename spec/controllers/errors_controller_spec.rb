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
        params[:individual_resolve] = true
        params[:id] = new_error.id
        put_with user, :resolve, params
        new_error.reload
        expect(new_error.status).to eq('resolved')
        expect(new_error.resolved_at).to be_truthy
      end

      it 'unresolves a single error' do
        new_error  = FactoryGirl.create(:grouped_issue, { website: website, checksum: SecureRandom.hex(), status: 'resolved', resolved_at: DateTime.now } )
        params[:individual_resolve] = true
        params[:id] = new_error.id
        put_with user, :resolve, params
        new_error.reload
        expect(new_error.status).to eq('unresolved')
        expect(new_error.resolved_at).to eq(nil)
      end

      it 'resolves multiple errors' do
        new_error1  = FactoryGirl.create(:grouped_issue, { website: website, checksum: SecureRandom.hex(), status: 'unresolved', resolved_at: nil } )
        new_error2  = FactoryGirl.create(:grouped_issue, { website: website, checksum: SecureRandom.hex(), status: 'unresolved', resolved_at: nil } )
        params[:error_ids] = [new_error1.id, new_error2.id]
        params[:resolved] = "false"
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
        params["resolved"] = "true"
        put_with user, :resolve, params
        new_error1.reload
        new_error2.reload
        expect([new_error1.status, new_error2.status]).to all(eq('unresolved'))
        expect([new_error1.resolved_at, new_error2.resolved_at]).to all(be_nil)
      end

      it "raises 'Could not find error!' if we dont pass the ids" do
        expect{ put_with user, :resolve, params }.to raise_error("Could not find error!")
      end
    end
  end

  describe "private methods" do
    let(:params) { default_params.merge(id: group.id, website_id: website.id, current_tab: 'aggregations') }

    context "resolve_issues" do
      it "returns the next issues in the list and updates pagination" do
        controller = ErrorsController.new
        errors = []

        number_of_errors = 20
        number_of_errors.times do |index|
          new_error = FactoryGirl.create(:grouped_issue, { website: website, checksum: SecureRandom.hex(), status: 'resolved', resolved_at: DateTime.now } )
          errors.push(new_error)
        end
        errors.sort_by!(&:last_seen).reverse!

        #params
        ids_sent = errors.first(5).map(&:id)   #selected errors
        current_error = errors.first           #@error
        resolved = true                        #status
        per_page = offset = 5                  #number of items per page
        page = 1                               #current page

        controller.instance_eval { resolve_issues(ids_sent, resolved, per_page, page, current_error ) }
        # remove the first 5 since their status was updated
        errors.shift(per_page)
        sidebar = controller.instance_eval { @sidebar }
        expect(sidebar).to match_array(errors[per_page..per_page + 4])

        pagination = controller.instance_eval { @pagination }
        # start_value - end_value of total_count
        # eg: 5 - 10 of 15
        start_value = pagination.offset_value + 1
        end_value = pagination.last_page? ? pagination.total_count : pagination.offset_value + pagination.limit_value

        expect(start_value).to eq(per_page + 1)
        expect(end_value).to eq(per_page + ids_sent.size)
      end
    end

    context 'aggregation' do
      it 'returns different browser occurences' do
        mozilla_browser = '{"server_name":"sergiu-Lenovo-IdeaPad-Y510P","modules":{"rake":"10.4.2","i18n":"0.7.0","json":"1.8.3","minitest":"5.8.2","thread_safe":"0.3.5","tzinfo":"1.2.2","activesupport":"4.2.1","builder":"3.2.2","erubis":"2.7.0","mini_portile":"0.6.2","nokogiri":"1.6.6.2","rails-deprecated_sanitizer":"1.0.3","rails-dom-testing":"1.0.7","loofah":"2.0.3","rails-html-sanitizer":"1.0.2","actionview":"4.2.1","rack":"1.6.4","rack-test":"0.6.3","actionpack":"4.2.1","globalid":"0.3.6","activejob":"4.2.1","mime-types":"2.6.2","mail":"2.6.3","actionmailer":"4.2.1","activemodel":"4.2.1","arel":"6.0.3","activerecord":"4.2.1","debug_inspector":"0.0.2","binding_of_caller":"0.7.2","bundler":"1.11.2","coderay":"1.1.0","coffee-script-source":"1.10.0","execjs":"2.6.0","coffee-script":"2.4.1","thor":"0.19.1","railties":"4.2.1","coffee-rails":"4.1.0","multipart-post":"2.0.0","faraday":"0.9.2","multi_json":"1.11.2","jbuilder":"2.3.2","jquery-rails":"4.0.5","method_source":"0.8.2","slop":"3.6.0","pry":"0.10.3","sprockets":"3.4.0","sprockets-rails":"2.3.3","rails":"4.2.1","rdoc":"4.2.0","sass":"3.4.19","tilt":"2.0.1","sass-rails":"5.0.4","sdoc":"0.4.1","sentry-raven":"0.15.2","spring":"1.4.1","sqlite3":"1.3.11","turbolinks":"2.5.3","uglifier":"2.7.2","web-console":"2.2.1"},"extra":{},"tags":{},"errors":[{"type":"invalid_data","name":"timestamp","value":"2016-02-15T06:01:29"}],"interfaces":{"exception":{"values":[{"type":"ZeroDivisionError","value":"\"divided by 0\"","module":"","stacktrace":{"frames":[{"abs_path":"\/home\/sergiu\/.rvm\/rubies\/ruby-2.2.2\/lib\/ruby\/2.2.0\/webrick\/server.rb","filename":"webrick\/server.rb","function":"block in start_thread","context_line":"          block ? block.call(sock) : run(sock)\n","pre_context":["module ActionController\n","  module ImplicitRender\n","    def send_action(method, *args)\n"],"post_context":["      default_render unless performed?\n","      ret\n","    end\n"],"lineno":4},{"abs_path":"\/home\/sergiu\/ravenapp\/app\/controllers\/home_controller.rb","filename":"app\/controllers\/home_controller.rb","function":"index","context_line":"    1\/0\n","pre_context":["  # Prevent CSRF attacks by raising an exception.\n","  # For APIs, you may want to use :null_session instead.\n","  def index\n"],"post_context":["  end\n","end\n",""],"lineno":5},{"abs_path":"\/home\/sergiu\/ravenapp\/app\/controllers\/home_controller.rb","filename":"app\/controllers\/home_controller.rb","function":"\/","context_line":"    1\/0\n","pre_context":["  # Prevent CSRF attacks by raising an exception.\n","  # For APIs, you may want to use :null_session instead.\n","  def index\n"],"post_context":["  end\n","end\n",""],"lineno":5}],"frames_omitted":null,"has_frames":true}}],"exc_omitted":null},"http":{"env":{"REMOTE_ADDR":"127.0.0.1","SERVER_NAME":"localhost","SERVER_PORT":"3001"},"headers":[{"host":"localhost:3001"},{"connection":"keep-alive"},{"accept":"text\/html,application\/xhtml+xml,application\/xml;q=0.9,image\/webp,*\/*;q=0.8"},{"upgrade_insecure_requests":"1"},{"user_agent":"Mozilla\/5.0 (X11; Linux x86_64) Gecko\/20100101 Firefox\/46.0"},{"accept_encoding":"gzip, deflate, sdch"},{"accept_language":"en-US,en;q=0.8"},{"cookie":"currentConfigName=%22default%22; pickedWebsite=1; _epiclogger_session=NTIwU2prYUd2T0dEd3FGQWE0WUFaL3RDY0huRGFnV1Z5TEhOQ3RtWUZZTTVRSzgvRTZvdEI2SFRsSVQ0ajVidHRWQnA5ck9wT3ZQU095N0dkWjEza0dpYWlmekxyRzFJbEFVNk5zRExmMzg3Q2c2MFBWdi9UYVUyWjdkWHVMNUFaWFJzZ2pEMGdwd3JJSGpSNjlEK2o3ZjlWZEhISEprK1hXOFNvaGdRdHg2MkFxN0lrcmlIdUtQazVWUjNGaWJvUGVYTHJncEc2OWhpaHBZbXNqcVhUcjM0ZWQ5bDFnWDBVSGlaOE5rdGxiOHNDU2NUS3BaSjd4eUZSRklzVnU5M3Z0TmJLUzF6ZWxjOGUrRmF2NkZ6ZCtGMUdoQVdFUSt0am9KT2lDODRMckJwbWQ1ZU5hV1hhZmt2bHdDZHZibEFmMExXNTI5Tmt..."},{"version":"HTTP\/1.1"}],"url":"http:\/\/localhost\/\/"}},"site":null,"environment":null,"version":"5"}'
        issue2 = FactoryGirl.create(:issue, subscriber: subscriber, group: group, data: mozilla_browser )

        get_with user, :show, params, { epiclogger_website_id: website.id }
        expect(assigns(:aggregations)[:browsers][0]["name"]).to eq('Chrome')
        expect(assigns(:aggregations)[:browsers][1]["name"]).to eq('Firefox')
      end

      it 'returns different messages' do
        different_message = "mesaju vietii"
        issue3 = FactoryGirl.create(:issue, subscriber: subscriber, group: group, message: different_message )

        get_with user, :show, params, { epiclogger_website_id: website.id }
        expect(assigns(:aggregations)[:messages][0]["message"]).to eq('ZeroDivisionError: divided by 0')
        expect(assigns(:aggregations)[:messages][1]["message"]).to eq('mesaju vietii')
      end

      it 'returns different subscribers' do
        subscriber2 = FactoryGirl.create(:subscriber, website: website, email: 'gogu@yahoo.com')
        issue4 = FactoryGirl.create(:issue, subscriber: subscriber2, group: group)

        get_with user, :show, params, { epiclogger_website_id: website.id }
        expect(assigns(:aggregations)[:subscribers][0]["id"]).to eq(subscriber.id)
        expect(assigns(:aggregations)[:subscribers][1]["id"]).to eq(subscriber2.id)
      end
    end
  end
end
