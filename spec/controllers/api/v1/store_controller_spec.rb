require 'rails_helper'

describe Api::V1::StoreController, :type => :controller do
  let(:member) { create :member }
  let(:website) { create :website }
  let!(:website_member) { create :website_member, website: website, member: member }
  let(:group) {create :grouped_issue, website: website}
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_error) { create :issue, subscriber: subscriber, group: group }
  let(:message) { 'asdada' }
  let(:default_params) { {sentry_key: website.app_key, id: website.id, format: :json} }

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
      }})
    }
    shared_examples 'creates error' do
      it 'should get current site' do
        request.env['HTTP_APP_ID'] = website.app_id
        request.env['HTTP_APP_KEY'] = website.app_key
        post :create, params
        expect(assigns(:current_site)).to eq(website)
      end

      it 'should create subscriber' do
        expect {
          post :create, params
        }.to change(Subscriber, :count).by( 1 )
      end

      it 'should create issue' do
        expect {
          post :create, params
        }.to change(Issue, :count).by( 1 )
      end

      it 'should create message' do
        expect {
          post :create, params
        }.to change(Message, :count).by( 1 )
      end

      it 'should not create subscriber if subscriber exists' do
        subscriber1 = create :subscriber, website: website, name: 'Name for subscriber', email: 'email@example2.com'
        error1 = create :issue, subscriber: subscriber, group: group, page_title: 'New title'
        expect{
          post :create, params
        }.to change(Subscriber, :count).by(0)
      end
    end

    context 'if logged in' do
      before { auth_member(member) }
      it_behaves_like 'creates error'
    end

    context 'not logged in' do
      it_behaves_like 'creates error'
    end
  end
end