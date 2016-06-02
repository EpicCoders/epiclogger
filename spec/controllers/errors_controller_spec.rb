require 'rails_helper'

RSpec.describe ErrorsController, type: :controller do
  let(:user) { create :user }
  let(:website) { create :website }
  let!(:website_member) { create :website_member, website: website, user: user }
  let(:group) { create :grouped_issue, website: website, last_seen: Time.now - 1.day }
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_error) { create :issue, subscriber: subscriber, group: group }
  let(:message) { 'asdada' }

  describe 'POST #notify_subscribers' do
    context 'if logged in' do
      let(:params) { { message: message, id: group.id, format: :js } }

      it 'should email subscribers' do
        params[:format] = 'js'
        mailer = double('GroupedIssueMailer')
        expect(mailer).to receive(:deliver_later)
        expect(GroupedIssueMailer).to receive(:notify_subscriber).with(group, user, user, message).and_return(mailer).once

        post_with user, :notify_subscribers, params
      end

      it 'should email 2 subscribers' do
        user2 = create :user, provider: "some"
        create :website_member, website: website, user_id: user2.id
        mailer = double('GroupedIssueMailer')
        expect(mailer).to receive(:deliver_later).twice
        expect(GroupedIssueMailer).to receive(:notify_subscriber).with(group, an_instance_of(User), an_instance_of(User), message).and_return(mailer).twice
        post_with user, :notify_subscribers, params
      end

      it 'assigns message' do
        post_with user, :notify_subscribers, params
        expect(assigns(:message)).to eq('asdada')
      end
    end

    describe 'GET #index' do
      let(:params) { { current_issue: issue_error.id } }

      context 'if logged in' do
        it 'assigns current_site errors' do
          get_with user, :index, params, { epiclogger_website_id: website.id}
          expect(assigns(:errors)).to eq([group])
        end
      end
    end
    context 'not logged in' do
      let(:params) { { current_issue: issue_error.id } }

      it 'should give error if not logged in' do
        get :index, params
        expect(response).to have_http_status(302)
      end
    end
  end

  describe 'GET #show' do
    let(:params) { { status: 'resolved', id: group.id, website_id: website.id } }
    render_views
    context 'if logged in' do

      context "when we go to an individual error from the general sidebar in  errors#index" do
        before(:each) do session[:epiclogger_website_id] = website.id end
        let!(:errors) do
          array = []
          number_of_errors = 5
          number_of_errors.times do |index|
            unresolved_error = FactoryGirl.create(:grouped_issue, { website: website, checksum: SecureRandom.hex(), status: 'unresolved', resolved_at: nil, last_seen: Time.now } )
            resolved_error = FactoryGirl.create(:grouped_issue, { website: website, checksum: SecureRandom.hex(), status: 'resolved', resolved_at: Time.now, last_seen: Time.now } )
            array.push(resolved_error, unresolved_error)
          end
          array.sort_by!(&:last_seen).reverse!
        end

        it "displays the page of the current error when no other url params are present" do
          get_with user, :show, params
          expect(assigns(:selected_errors).current_page).to eq(2)
        end

        it "displays resolved issues when on the resolved tab" do
          params[:tab] = 'resolved'
          get_with user, :show, params
          expect(assigns(:selected_errors).map(&:resolved?)).to all(be true)
        end

        it 'assigns chart_data' do
          get_with user, :show, params
          expect(assigns(:chart_data).count).to eq(32)
        end

        it "displays the page we request via param" do
          params[:tab] = 'unresolved'
          params[:page] = 2
          get_with user, :show, params
          expect(assigns(:selected_errors).current_page).to eq(2)
          expect(assigns(:selected_errors)).to_not be_empty
        end
      end
    end

    it 'should give error if not logged in' do
      get :show, params, { epiclogger_website_id: website.id}
      expect(response).to have_http_status(302)
    end
  end

  describe 'PUT #update' do
    let(:params) { { error: { status: 'resolved' }, id: group.id, website_id: website.id } }
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
          put_with user, :update, id: group.id, error: { error: 'some' }, website_id: website.id
        }.to_not change(group, :status).from('unresolved')
      end
    end
    context 'not logged in' do
      let(:params) { { status: 'resolved', id: group.id, website_id: website.id } }
      it 'throws unauthorized' do
        get :update, params
        expect(response).to have_http_status(302)
      end
    end
  end

  describe 'PUT #resolve' do
    let(:params) { { id: group.id } }
    context 'logged in' do
      before(:each) do session[:epiclogger_website_id] = website.id end
      it 'resolves a single error' do
        new_error  = FactoryGirl.create(:grouped_issue, { website: website, checksum: SecureRandom.hex(), status: 'unresolved', resolved_at: nil } )
        params[:error_ids] = [new_error.id]
        put_with user, :resolve, params
        new_error.reload
        expect(new_error.resolved?).to be true
      end

      it 'unresolves a single error' do
        new_error  = FactoryGirl.create(:grouped_issue, { website: website, checksum: SecureRandom.hex(), status: 'resolved', resolved_at: DateTime.now } )
        params[:error_ids] = [new_error.id]
        put_with user, :unresolve, params
        new_error.reload
        expect(new_error.unresolved?).to be true
      end

      it 'resolves multiple errors' do
        new_error1  = FactoryGirl.create(:grouped_issue, { website: website, checksum: SecureRandom.hex(), status: 'unresolved', resolved_at: nil } )
        new_error2  = FactoryGirl.create(:grouped_issue, { website: website, checksum: SecureRandom.hex(), status: 'unresolved', resolved_at: nil } )
        params[:error_ids] = [new_error1.id, new_error2.id]
        put_with user, :resolve, params
        new_error1.reload
        new_error2.reload
        expect([new_error1.resolved?, new_error2.resolved?]).to all(be true)
      end

      it 'unresolves multiple errors' do
        new_error1  = FactoryGirl.create(:grouped_issue, { website: website, checksum: SecureRandom.hex(), status: 'resolved', resolved_at: DateTime.now } )
        new_error2  = FactoryGirl.create(:grouped_issue, { website: website, checksum: SecureRandom.hex(), status: 'resolved', resolved_at: DateTime.now } )
        params[:error_ids] = [new_error1.id, new_error2.id]
        put_with user, :unresolve, params
        new_error1.reload
        new_error2.reload
        expect([new_error1.unresolved?, new_error2.unresolved?]).to all(be true)
      end

      it 'redirects to errors#show after resolving' do
        new_error  = FactoryGirl.create(:grouped_issue, { website: website, checksum: SecureRandom.hex(), status: 'resolved', resolved_at: DateTime.now } )
        params[:error_ids] = [new_error.id]
        expect(put_with user, :resolve, params).to redirect_to(error_path(id: group.id))
      end

      it 'redirects to errors#show after unresolving' do
        new_error  = FactoryGirl.create(:grouped_issue, { website: website, checksum: SecureRandom.hex(), status: 'resolved', resolved_at: DateTime.now } )
        params[:error_ids] = [new_error.id]
        expect(put_with user, :unresolve, params).to redirect_to(error_path(id: group.id))
      end
    end
  end
end
