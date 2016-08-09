require 'rails_helper'

RSpec.describe ErrorsController, type: :controller do
  let(:user) { create :user }
  let(:website) { create :website }
  let!(:website_member) { create :website_member, website: website, user: user }
  let(:group) { create :grouped_issue, website: website, platform: 'ruby', last_seen: Time.now - 1.day }
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_error) { create :issue, subscriber: subscriber, group: group }
  let(:message) { create :message, issue: issue_error }

  describe 'POST #notify_subscribers' do
    context 'if logged in' do
      let(:params) { { message: 'message that is going to create record', id: group.id, format: :js } }

      context 'email' do
        it 'should email subscribers' do
          mailer = double('GroupedIssueMailer')
          expect(mailer).to receive(:deliver_later)
          expect(GroupedIssueMailer).to receive(:notify_subscriber).with(group, subscriber, user, an_instance_of(Message)).and_return(mailer).once

          post_with user, :notify_subscribers, params
        end

        it 'should email 2 subscribers' do
          subscriber2 = create :subscriber, website: website
          issue2 = create :issue, subscriber: subscriber2, group: group
          mailer = double('GroupedIssueMailer')
          expect(mailer).to receive(:deliver_later).twice
          expect(GroupedIssueMailer).to receive(:notify_subscriber).with(group, an_instance_of(Subscriber), an_instance_of(User), an_instance_of(Message)).and_return(mailer).twice
          post_with user, :notify_subscribers, params
        end

        it 'assigns message' do
          post_with user, :notify_subscribers, params
          expect(subject.instance_variable_get(:@message)).to be_an_instance_of(Message)
        end

        it 'redirects to the error path with success message' do
          post_with user, :notify_subscribers, params
          expect(response).to redirect_to(error_path(group.slug))
          expect(flash[:success]).to eq('Message successfully sent!')
        end
      end

      context 'intercom' do
        let!(:integration) { create :integration, website: website, provider: :intercom }
        let(:driver) { Integrations.get_driver(integration.provider.to_sym) }
        let(:integration_driver) { driver.new(Integrations::Integration.new(integration, driver)) }
        before(:each) do session[:epiclogger_website_id] = website.id end
        let(:intercom_params) { params.merge( intercom: true ) }

        context 'success' do
          it 'calls the send_message method in the driver' do
            expect_any_instance_of(Integrations::Drivers::Intercom).to receive(:send_message)
            post_with user, :notify_subscribers, intercom_params
          end

          it 'redirects to the error with success message' do
            stub_request(:post, integration_driver.api_url + 'messages')
            .with(:body => "{\"message_type\":\"inapp\",\"body\":\"message that is going to create record\",\"template\":\"plain\",\"from\":{\"type\":\"admin\",\"id\":\"12345\"},\"to\":{\"type\":\"user\",\"email\":\"" + group.subscribers.first.email + "\"}}",
                  :headers => {'Authorization'=>'Basic Og=='})
            .to_return(:status => 200, :body => web_response_factory('intercom/intercom_post_message'), :headers => {})
            post_with user, :notify_subscribers, intercom_params
            expect(response).to redirect_to(error_path(group.slug))
            expect(flash[:success]).to eq('Message successfully sent!')
          end
        end

        context 'failure' do

          it 'redirects to error path with error message if the message does not meet the criteria' do
            stub_request(:post, integration_driver.api_url + 'messages').
            with(:body => "{\"message_type\":\"inapp\",\"body\":\"smallmsg\",\"template\":\"plain\",\"from\":{\"type\":\"admin\",\"id\":\"12345\"},\"to\":{\"type\":\"user\",\"email\":\"" + group.subscribers.first.email + "\"}}",
                 :headers => {'Authorization'=>'Basic Og=='}).
            to_return(:status => 500, :body => "eroare", :headers => {})
            intercom_params[:message] = 'smallmsg'
            post_with user, :notify_subscribers, intercom_params
            expect(response).to redirect_to(error_path(group.slug))
            expect(flash[:error]).to eq('Message too short!')
          end

          it 'redirects to error path with error message if sending the message fails' do
            stub_request(:post, integration_driver.api_url + 'messages').
            with(:body => "{\"message_type\":\"inapp\",\"body\":\"message that is going to create record\",\"template\":\"plain\",\"from\":{\"type\":\"admin\",\"id\":\"12345\"},\"to\":{\"type\":\"user\",\"email\":\"" + group.subscribers.first.email + "\"}}",
                 :headers => {'Authorization'=>'Basic Og=='}).
            to_return(:status => 500, :body => "eroare", :headers => {})
            post_with user, :notify_subscribers, intercom_params
            expect(response).to redirect_to(error_path(group.slug))
            expect(flash[:error]).to eq('Operation failed!')
          end
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

  describe 'GET #index' do
    let(:params) { { current_issue: issue_error.id } }

    context 'if logged in' do
      it 'assigns current_site errors' do
        get_with user, :index, params, { epiclogger_website_id: website.id}
        expect(assigns(:errors)).to eq([group])
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
          number_of_errors = 25
          number_of_errors.times do |index|
            unresolved_error = FactoryGirl.create(:grouped_issue, { website: website, checksum: SecureRandom.hex(), status: 'unresolved', resolved_at: nil, last_seen: Time.now } )
            resolved_error = FactoryGirl.create(:grouped_issue, { website: website, checksum: SecureRandom.hex(), status: 'resolved', resolved_at: Time.now, last_seen: Time.now } )
            array.push(resolved_error, unresolved_error)
          end
          array.sort_by!(&:last_seen).reverse!
        end

        it "displays the page of the current error when no other url params are present" do
          get_with user, :show, params
          expect(assigns(:selected_errors).current_page).to eq(1)
        end

        it "displays resolved issues when on the resolved tab" do
          params[:tab] = 'resolved'
          get_with user, :show, params
          expect(assigns(:selected_errors).map(&:resolved?)).to all(be true)
        end

        it 'assigns chart_data and counts as 1 error' do
          get_with user, :show, params
          expect(assigns(:chart_data).sum(&:second)).to eq(1)
        end

        it "displays the page we request via param" do
          params[:tab] = 'resolved'
          params[:page] = 2
          get_with user, :show, params
          expect(assigns(:selected_errors).current_page).to eq(2)
          expect(assigns(:selected_errors)).to_not be_empty
        end
        context 'filters' do
          context 'search' do
            let(:params) { { id: group.id, website_id: website.id, commit: 'search-button'  } }
            it 'should return one match' do
              params[:search] = 'ruby'
              get_with user, :show, params
              expect(assigns(:selected_errors).count).to eq(1)
            end
            it 'should return 50 matches' do
              params[:search] = 'javascript'
              get_with user, :show, params
              expect(subject.matching_elements.count).to eq(50)

              expect(assigns(:selected_errors).count).to eq(5)
            end

            it 'should contain a flash message and return nil' do
              params[:search] = 'dorin chirtoaca'
              get_with user, :show, params
              expect(subject.matching_elements.count).to eq(0)
              expect(flash[:notice]).to eq("No matches")
            end
          end
          context 'filter by date' do
            before(:each) do
              errors[0].update_attributes(first_seen: errors[0].last_seen)
              errors[1].update_attributes(first_seen: errors[1].last_seen)
              errors[3].update_attributes(first_seen: errors[3].first_seen - 5.months, last_seen: errors[3].first_seen - 1.year)
            end
            context 'when range matches' do
              it 'should return 2 errors' do
                params[:status] = ''
                params[:datepicker] = "#{Date.today.strftime("%d/%m/%Y")} - #{Date.today.strftime("%d/%m/%Y")}"

                get_with user, :show, params
                expect(assigns(:selected_errors).count).to eq(2)
              end

              it 'should return nil' do
                params[:status] = ''
                params[:datepicker] = "#{(Date.today + 1.day).strftime("%d/%m/%Y")} - #{(Date.today + 1.day).strftime("%d/%m/%Y")}"

                get_with user, :show, params
                expect(assigns(:selected_errors).count).to eq(0)
              end
            end

            context 'when range does not match' do
              it 'should return 1 error' do
                params[:status] = ''
                params[:datepicker] = "#{(Date.today - 2.years ).strftime("%d/%m/%Y")} - #{(Date.today - 4.months).strftime("%d/%m/%Y")}"

                get_with user, :show, params
                expect(assigns(:selected_errors).count).to eq(1)
              end

              it 'should return nil' do
                params[:status] = ''
                params[:datepicker] = "#{(Date.today - 5.years ).strftime("%d/%m/%Y")} - #{(Date.today - 6.years).strftime("%d/%m/%Y")}"

                get_with user, :show, params
                expect(assigns(:selected_errors).count).to eq(0)
              end
            end
          end
          context 'filter by status' do
            it 'should filter resolved errors' do
              params[:status] = 'resolved'
              get_with user, :show, params

              expect(assigns(:selected_errors).find_all{ |e| e.status == 'resolved' }.count).to eq(5)
            end

            it 'should filter unresolved errors' do
              params[:status] = 'unresolved'
              get_with user, :show, params

              expect(assigns(:selected_errors).find_all{ |e| e.status == 'unresolved' }.count).to eq(5)
            end

            it 'should return nil' do
              params[:status] = 'unresolved'
              get_with user, :show, params

              expect(assigns(:selected_errors).find_all{ |e| e.status == 'resolved' }.count).to eq(0)

              params[:status] = 'resolved'
              get_with user, :show, params

              expect(assigns(:selected_errors).find_all{ |e| e.status == 'unresolved' }.count).to eq(0)
            end
          end
          context 'filter by env' do
            it 'should return matches' do
              params[:status] = ''
              params[:env] = 'development'

              get_with user, :show, params
              expect(assigns(:selected_errors).count).to eq(5)
            end

            it 'should return nil' do
              params[:status] = ''
              params[:env] = 'staging'

              get_with user, :show, params
              expect(assigns(:selected_errors).count).to eq(0)
            end
          end
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
        expect(put_with user, :resolve, params).to redirect_to(error_url(group))
      end

      it 'redirects to errors#show after unresolving' do
        new_error  = FactoryGirl.create(:grouped_issue, { website: website, checksum: SecureRandom.hex(), status: 'resolved', resolved_at: DateTime.now } )
        params[:error_ids] = [new_error.id]
        expect(put_with user, :unresolve, params).to redirect_to(error_url(group))
      end
    end
  end
end
