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
    let(:params) { { "event_id"=>"eccf7cd6c0e095e9679bd1cd221734bc",
                     "message"=>"ZeroDivisionError: divided by 0",
                     "timestamp"=>"2015-11-14T15:21:49",
                     "time_spent"=>170,
                     "level"=>40,
                     "project"=>nil,
                     "platform"=>"ruby",
                     "logger"=>"",
                     "culprit"=>"app/controllers/home_controller.rb in / at line 5",
                     "server_name"=>"imac.local",
                     "modules"=> {"rake"=>"10.4.2", "i18n"=>"0.7.0"},
                     "extra"=>{},
                     "tags"=>{},
                     "user"=>{"email"=>"gogu@gmail.com"},
                     "exception"=>
                            {"values"=>
                                [{"type"=>"ZeroDivisionError",
                                  "value"=>"divided by 0",
                                  "module"=>"",
                                  "stacktrace"=>
                                     {"frames"=>
                                       [{"pre_context"=>["            raise\n", "          end\n", "          call_callback(:AcceptCallback, sock)\n"],
                                         "post_context"=>
                                          ["        rescue Errno::ENOTCONN\n", "          @logger.debug \"Errno::ENOTCONN raised\"\n", "        rescue ServerError => ex\n"],
                                          "abs_path"=>"/Users/razvanciocanel/.rvm/rubies/ruby-2.2.1/lib/ruby/2.2.0/webrick/server.rb",
                                          "function"=>"block in start_thread",
                                          "lineno"=>294,
                                          "in_app"=>false,
                                          "context_line"=>"          block ? block.call(sock) : run(sock)\n",
                                          "project_root"=>"/Users/razvanciocanel/Development/ravenapp",
                                          "filename"=>"webrick/server.rb"}]
                                      }
                                }]
                            }
                    }
    }
    before { request.env['RAW_POST_DATA'] = Base64.strict_encode64(Zlib::Deflate.deflate(params.to_json)) }
    shared_examples 'creates error' do
      it 'should get current site' do
        request.env['HTTP_APP_ID'] = website.app_id
        request.env['HTTP_APP_KEY'] = website.app_key
        post :create, default_params
        expect(assigns(:current_site)).to eq(website)
      end

      it 'should create subscriber' do
        expect {
          post :create, default_params
        }.to change(Subscriber, :count).by( 1 )
      end

      it 'should create issue' do
        expect {
          post :create, default_params
        }.to change(Issue, :count).by( 1 )
      end

      it 'should create message' do
        expect {
          post :create, default_params
        }.to change(Message, :count).by( 1 )
      end

      it 'should not create subscriber if subscriber exists' do
        subscriber1 = create :subscriber, website: website, name: 'Name for subscriber', email: 'email@example2.com'
        error1 = create :issue, subscriber: subscriber, group: group, page_title: 'New title'
        expect{
          post :create, default_params
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

  describe 'GET #create' do

  end
end