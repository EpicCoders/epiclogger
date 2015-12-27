require 'rails_helper'

describe Api::V1::ErrorsController, :type => :controller do
  let(:member) { create :member }
  let(:website) { create :website }
  let!(:website_member) { create :website_member, website: website, member: member }
  let(:group) {create :grouped_issue, website: website}
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_error) { create :issue, subscriber: subscriber, group: group }
  let(:message) { 'asdada' }
  let(:default_params) { {website_id: website.id, format: :json} }

  describe 'POST #create' do
    let(:params) { default_params.merge({error:{
        user:{
            name: 'Gogu',
            email: 'email@example2.com'
          },
        culprit: "dasdas",
        logger: "javascript",
        name: 'Name for subscriber',
        extra:{
          title: 'New title'
      },
        request:{
          url: "http://www.example.com",
          headers:{
            "User-Agent" => "ReferenceError: fdas is not defined"
            }
          },
        stacktrace:{
          frames: [{filename: "http://www.example.com"}]
          },
        platform: "php",
        message: 'new message'
      }}) }

    context 'if logged in' do
      before { auth_member(member) }
      it 'should create subscriber' do
        expect {
          post :add_error, params
        }.to change(Subscriber, :count).by( 1 )
      end

      it 'should create issue' do
        expect {
          post :add_error, params
        }.to change(Issue, :count).by( 1 )
      end

      it 'should create message' do
        expect {
          post :add_error, params
        }.to change(Message, :count).by( 1 )
      end

      it 'should not create subscriber if subscriber exists' do
        subscriber1 = create :subscriber, website: website, name: 'Name for subscriber', email: 'email@example2.com'
        error1 = create :issue, subscriber: subscriber, group: group, page_title: 'New title'
        expect{
          post :add_error, params
        }.to change(Subscriber, :count).by(0)
      end
    end

    # context 'not logged in' do
    #   it 'should get current site' do
    #     request.env['HTTP_APP_ID'] = website.app_id
    #     request.env['HTTP_APP_KEY'] = website.app_key
    #     post :add_error, params
    #     expect(assigns(:current_site)).to eq(website)
    #   end
    # end
  end

  describe 'POST #notify_subscribers' do
    context 'if logged in' do
      before { auth_member(member) }
      let(:params) { default_params.merge({ message: message, id: group.id }) }

      it 'should email subscribers' do
        mailer = double('UserMailer')
        expect(mailer).to receive(:deliver_now)
        expect(UserMailer).to receive(:notify_subscriber).with(group, member, message).and_return(mailer).once

        post :notify_subscribers, params
      end

      it 'should email 2 subscribers' do
        member2 = create :member
        website_member = create :website_member, website: website, member: member2
        mailer = double('UserMailer')
        expect(mailer).to receive(:deliver_now).twice
        expect(UserMailer).to receive(:notify_subscriber).with(group, an_instance_of(Member), message).and_return(mailer).twice
        post :notify_subscribers, params
      end

      it 'should assign message' do
        post :notify_subscribers, params
        expect(assigns(:message)).to eq('asdada')
      end
    end

    describe 'GET #index' do
      let(:params) { default_params.merge({website_id: website.id}) }

      context 'if logged in' do
        before { auth_member(member) }

        it 'should render json' do
          get :index, params
          expect(response).to be_successful
          expect(response.content_type).to eq('application/json')
        end

        it 'should assign current_site errors' do
          auth_member(member)
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
    let(:params) { default_params.merge({ status: 'resolved', id: group.id, website_id: website.id}) }
    render_views
    context 'if logged in' do
      before { auth_member(member) }

      it 'should render json' do
        get :show, params
        expect(response).to be_successful
        expect(response.content_type).to eq('application/json')
      end

      it 'should render the expected json' do
        get :show, params
        expect(response).to be_successful
        expect(response.body).to eq({
          id: group.id,
          message: group.message,
          view: group.view,
          times_seen: group.times_seen,
          first_seen: group.first_seen,
          last_seen: group.last_seen,
          data: group.data,
          score: group.score,
          status: group.status,
          level: group.level,
          issue_logger: group.issue_logger,
          resolved_at: group.resolved_at,
          issues: [
            {
              id: issue_error.id,
              platform: issue_error.platform,
              page_title: issue_error.page_title,
              data: JSON.parse(issue_error.data),
              description: JSON.parse(issue_error.description),
              subscriber:{
                id: subscriber.id,
                email: subscriber.email,
                avatar_url: "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(subscriber.email)}"
              },
            subscribers_count: group.subscribers.count
            }
          ]
        }.to_json)
      end
    end

    it 'should give error if not logged in' do
      get :show, params
      expect(response.body).to eq({errors: ['Authorized users only.']}.to_json)
      expect(response).to have_http_status(401)
    end
  end

  describe 'PUT #update' do
    let(:params) { default_params.merge({ error: { status: 'resolved' }, id: group.id, website_id: website.id}) }
    context 'if logged in' do
      before { auth_member(member) }
      it 'should assign error' do
        put :update, params
        expect(assigns(:error)).to eq(group)
      end
      it 'should update error status' do
        expect {
          put :update, params
          group.reload
        }.to change(group, :status).from('unresolved').to('resolved')
      end

      it 'should not allow update of other parameters other than status' do
        expect{
          put :update, { id: group.id, error: { error: 'some' }, website_id: website.id, format: :json }
        }.to_not change(group, :status).from("unresolved")
      end

      it 'should render json' do
        put :update, params
        expect(response).to be_successful
        expect(response.content_type).to eq('application/json')
      end
    end
    context 'not logged in' do
      let(:params) { default_params.merge({ status: 'resolved', id: group.id, website_id: website.id}) }
      it 'should throw unauthorized' do
        get :update, params
        expect(response.body).to eq({errors: ['Authorized users only.']}.to_json)
        expect(response).to have_http_status(401)
      end
    end
  end
end