require "rails_helper"

describe GroupedIssueMailer do
  let(:user) { create :user, reset_password_token: 'KlQFgx2ckDmJsvnbbj3CRw', confirmed_at: Time.now, confirmation_token: 'vJq2UGPUDBZYcO7RiuxkAw'}
  let(:website) { create :website }
  let!(:website_member) { create :website_member, website: website, user: user }
  let(:group) { create :grouped_issue, website: website, last_seen: Time.now - 1.day, culprit: 'index.php:Raven_ErrorHandler in handleError', message: 'Undefined variable: ex', created_at: Time.now, checksum: '5ae79a60e5a97b0977e01b525c779e49'  }
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue1) { create :issue, subscriber: subscriber, group: group, platform: 'ruby', event_id: '7663e5a972341e047cd2820fd00c518d', message: 'Message that something went wrong', created_at: Time.now, data: '{"server_name":"sergiu-Lenovo-IdeaPad-Y510P","modules":{"rake":"10.4.2","i18n":"0.7.0","json":"1.8.3","minitest":"5.8.2","thread_safe":"0.3.5","tzinfo":"1.2.2","activesupport":"4.2.1","builder":"3.2.2","erubis":"2.7.0","mini_portile":"0.6.2","nokogiri":"1.6.6.2","rails-deprecated_sanitizer":"1.0.3","rails-dom-testing":"1.0.7","loofah":"2.0.3","rails-html-sanitizer":"1.0.2","actionview":"4.2.1","rack":"1.6.4","rack-test":"0.6.3","actionpack":"4.2.1","globalid":"0.3.6","activejob":"4.2.1","mime-types":"2.6.2","mail":"2.6.3","actionmailer":"4.2.1","activemodel":"4.2.1","arel":"6.0.3","activerecord":"4.2.1","debug_inspector":"0.0.2","binding_of_caller":"0.7.2","bundler":"1.11.2","coderay":"1.1.0","coffee-script-source":"1.10.0","execjs":"2.6.0","coffee-script":"2.4.1","thor":"0.19.1","railties":"4.2.1","coffee-rails":"4.1.0","multipart-post":"2.0.0","faraday":"0.9.2","multi_json":"1.11.2","jbuilder":"2.3.2","jquery-rails":"4.0.5","method_source":"0.8.2","slop":"3.6.0","pry":"0.10.3","sprockets":"3.4.0","sprockets-rails":"2.3.3","rails":"4.2.1","rdoc":"4.2.0","sass":"3.4.19","tilt":"2.0.1","sass-rails":"5.0.4","sdoc":"0.4.1","sentry-raven":"0.15.2","spring":"1.4.1","sqlite3":"1.3.11","turbolinks":"2.5.3","uglifier":"2.7.2","web-console":"2.2.1"},"extra":{},"tags":{},"errors":[{"type":"invalid_data","name":"timestamp","value":"2016-02-15T06:01:29"}],"interfaces":{"exception":{"values":[{"type":"ZeroDivisionError","value":"\"divided by 0\"","module":"","stacktrace":{"frames":[{"abs_path":"\/home\/sergiu\/.rvm\/rubies\/ruby-2.2.2\/lib\/ruby\/2.2.0\/webrick\/server.rb","filename":"webrick\/server.rb","function":"block in start_thread","context_line":"          block ? block.call(sock) : run(sock)\n","pre_context":["module ActionController\n","  module ImplicitRender\n","    def send_action(method, *args)\n"],"post_context":["      default_render unless performed?\n","      ret\n","    end\n"],"lineno":4},{"abs_path":"\/home\/sergiu\/ravenapp\/app\/controllers\/home_controller.rb","filename":"app\/controllers\/home_controller.rb","function":"index","context_line":"    1\/0\n","pre_context":["  # Prevent CSRF attacks by raising an exception.\n","  # For APIs, you may want to use :null_session instead.\n","  def index\n"],"post_context":["  end\n","end\n",""],"lineno":5},{"abs_path":"\/home\/sergiu\/ravenapp\/app\/controllers\/home_controller.rb","filename":"app\/controllers\/home_controller.rb","function":"\/","context_line":"    1\/0\n","pre_context":["  # Prevent CSRF attacks by raising an exception.\n","  # For APIs, you may want to use :null_session instead.\n","  def index\n"],"post_context":["  end\n","end\n",""],"lineno":5}],"frames_omitted":null,"has_frames":true}}],"exc_omitted":null},"http":{"env":{"REMOTE_ADDR":"127.0.0.1","SERVER_NAME":"localhost","SERVER_PORT":"3001"},"headers":[{"host":"localhost:3001"},{"connection":"keep-alive"},{"accept":"text\/html,application\/xhtml+xml,application\/xml;q=0.9,image\/webp,*\/*;q=0.8"},{"upgrade_insecure_requests":"1"},{"user_agent":"Mozilla\/5.0 (X11; Linux x86_64) Gecko\/20100101 Firefox\/46.0"},{"accept_encoding":"gzip, deflate, sdch"},{"accept_language":"en-US,en;q=0.8"},{"cookie":"currentConfigName=%22default%22; pickedWebsite=1; _epiclogger_session=NTIwU2prYUd2T0dEd3FGQWE0WUFaL3RDY0huRGFnV1Z5TEhOQ3RtWUZZTTVRSzgvRTZvdEI2SFRsSVQ0ajVidHRWQnA5ck9wT3ZQU095N0dkWjEza0dpYWlmekxyRzFJbEFVNk5zRExmMzg3Q2c2MFBWdi9UYVUyWjdkWHVMNUFaWFJzZ2pEMGdwd3JJSGpSNjlEK2o3ZjlWZEhISEprK1hXOFNvaGdRdHg2MkFxN0lrcmlIdUtQazVWUjNGaWJvUGVYTHJncEc2OWhpaHBZbXNqcVhUcjM0ZWQ5bDFnWDBVSGlaOE5rdGxiOHNDU2NUS3BaSjd4eUZSRklzVnU5M3Z0TmJLUzF6ZWxjOGUrRmF2NkZ6ZCtGMUdoQVdFUSt0am9KT2lDODRMckJwbWQ1ZU5hV1hhZmt2bHdDZHZibEFmMExXNTI5Tmt..."},{"version":"HTTP\/1.1"}],"url":"http:\/\/localhost\/\/"}},"site":null,"environment":null,"version":"5"}' }
  let(:message) { create :message, issue: issue1}

  describe 'notify_subscriber' do
    let(:sender) { create :user, email: 'sender@email.com', provider: 'coca-cola' }
    let(:mail) { described_class.notify_subscriber(group, user, sender, message) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Epic Logger Subscriber notification')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["admin@epiclogger.com"])
    end

    it 'renders the body' do
      expect(mail.body.parts.first.body.raw_source).to eq("From: #{sender.name}\nHi, #{user.name},\n#{message.content}\nThis email was sent because you subscribed to an error on our website.\n\n")
    end
  end

  describe 'error_occurred' do
    let(:mail) { described_class.error_occurred(issue1, website_member) }

    it 'renders the headers' do
      expect(mail.subject).to eq("[#{website.title}] #{issue1.message}")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["admin@epiclogger.com"])
    end

    it 'renders the body' do
      expect(mail.body.parts.first.body.raw_source).to eq("An error has just occurred. View full details at:\n<a target=\"_blank\" href=\"http://localhost:3000/errors/#{issue1.id}\">http://localhost:3000/errors/#{issue1.id}</a>\nError type\nZeroDivisionError\nError message\n&quot;divided by 0&quot;\nWhen\n#{issue1.created_at}\nWhere\n#{issue1.get_frames(:abs_path) || '<no information>' }\nFile\n#{issue1.get_frames(:filename) || '<no information>'}\nUrl\n#{issue1.http_data(:url)}\nBacktrace Summary\napp/controllers/home_controller.rb:5 in /\napp/controllers/home_controller.rb:5 in index\nwebrick/server.rb:4 in block in start_thread\n\n")
    end
  end

  describe 'more_than_10_errors' do
    let(:mail) { described_class.more_than_10_errors(website_member) }
    before(:each) { create_list(:issue, 11, group: group) }

    it 'renders the headers' do
      expect(mail.subject).to eq("[#{website.title}] This is a email notifying you that 10 errors occurred in last hour.")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["admin@epiclogger.com"])
    end

    it 'renders the body' do
      expect(mail.body.parts.first.body.raw_source).not_to be_nil
    end
  end

  context 'issues from all websites in one mail' do
    let(:websites) { user.websites }
    describe 'notify_daily' do
      let(:mail) { described_class.notify_daily(user, websites) }

      it 'renders the headers' do
        expect(mail.subject).to eq("Daily report email provides you some information about changes on your website.")
        expect(mail.to).to eq([user.email])
        expect(mail.from).to eq(["admin@epiclogger.com"])
      end

      it 'renders the body' do
        expect(mail.body.parts.first.body.raw_source).to eq( "Title: #{website.title}\nDomain: #{website.domain}\nPlatform: #{website.platform}\nCreated At: #{website.created_at}\nMessage: #{group.message}\nLevel: #{group.level}\nTimes seen: #{group.times_seen}\nCulprit: #{group.culprit}\n++++++++++++++++++++++++++++++++\n\n")
      end
    end

    describe 'notify_weekly' do
      let(:mail) { described_class.notify_weekly(user, websites) }

      it 'renders the headers' do
        expect(mail.subject).to eq("Weekly report email provides you some information about changes on your website.")
        expect(mail.to).to eq([user.email])
        expect(mail.from).to eq(["admin@epiclogger.com"])
      end

      it 'renders the body' do
        days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']
        expect(mail.body.parts.first.body.raw_source).to eq("Title: #{website.title}\nDomain: #{website.domain}\nPlatform: #{website.platform}\nCreated At: #{website.created_at}\nErrors that occurred on #{days[Time.now.wday-1].capitalize}\n''''''''''''''''''''''''''''''''''''''''''''''''''\nMessage: #{group.message}\nLevel: #{group.level}\nTimes seen: #{group.times_seen}\nCulprit: #{group.culprit}\nMore details: <a href=\"#{error_url(group)}\">#{error_url(group)}</a>\n++++++++++++++++++++++++++++++++\n\n")
      end
    end
  end
end