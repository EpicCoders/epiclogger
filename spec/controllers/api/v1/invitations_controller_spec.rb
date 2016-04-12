require 'rails_helper'

describe Api::V1::InvitationsController, :type => :controller do
  let(:user) { create :user }
  let(:website) { create :website }
  let!(:website_member) { create :website_member, user_id: user.id, website_id: website.id, invitation_sent_at: Time.now.utc }
  let(:default_params) { {website_id: website.id, format: :json} }

  render_views # this is used so we can check the json response from the controller

  xdescribe 'POST #create' do
    let(:params) { default_params.merge({user: { email: user.email }}) }

    context 'if logged in' do
      before { auth_user(user) }

      it 'should assign user' do
        post :create, params
        expect(assigns(:current_user)).to eq(user)
      end

      it 'should render json' do
        post :create, params
        expect(response).to be_successful
        expect(response.content_type).to eq('application/json')
      end
      context 'not website of current user' do
        let(:website2) { create :website }
        let(:params) { default_params.merge({user: { email: user.email }, website_id: website2.id }) }
        it 'should not create user' do
          expect {
            post :create, params
          }.to change(WebsiteMember, :count).by( 0 )
        end
        it 'should raise 401 not authorized' do
          post :create, params
          expect(response.body).to eq({errors: 'You are not the user of this website.'}.to_json)
          expect(response).to have_http_status(401)
        end
      end

      it 'should create website_user' do
        expect {
          post :create, params
        }.to change(WebsiteMember, :count).by( 1 )
      end

      it 'should email user' do
        mailer = double('UserMailer')
        expect(mailer).to receive(:deliver_now)
        expect(UserMailer).to receive(:member_invitation).with(website.id, user.email, an_instance_of(Fixnum), user.id).and_return(mailer).once

        post :create, params
      end
      it 'should render some message' do
        post :create, params
        expect(response.body).to eq({success: true, message: 'Invitation created and sent'}.to_json)
      end
    end
    it 'should give error if not logged in' do
      post :create, params
      expect(response.body).to eq({errors: ['Authorized users only.']}.to_json)
      expect(response).to have_http_status(401)
    end
  end
end
