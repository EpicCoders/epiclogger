require 'rails_helper'

describe Issue do

  let(:user) { create :user }
  let(:website) { create :website }
  let!(:website_member) { create :website_member, website: website, user: user }
  let!(:grouped_issue) { create :grouped_issue, website: website }
  let(:issue) { create :issue, group: grouped_issue }

  it "has a valid factory" do
    expect(build(:issue, group: nil)).to be_valid
  end

  describe "ActiveRecord associations" do
    it "belongs to subscriber" do
      expect(issue).to belong_to(:subscriber)
    end

    it "belongs to grouped issue" do
      expect(issue).to belong_to(:group).class_name('GroupedIssue')
    end

    it "has many messages" do
      expect(issue).to have_many(:messages)
    end

    it 'delegate' do
      expect(subject).to delegate_method(:website).to(:group)
    end

    it 'accepts nested attributes' do
      expect(subject).to accept_nested_attributes_for(:messages)
    end

    it 'should have message' do
      expect(subject).to validate_presence_of(:message)
    end
  end

  describe "error" do
    it 'should call find' do
      expect( ErrorStore).to receive(:find).with(issue)
      issue.error
    end

    it "should return ErrorStore instance" do
      expect( issue.error ).to be_kind_of(ErrorStore::Error)
    end
  end

  describe "user_agent" do
    it "returns user agent" do
      expect(issue.user_agent.browser).to eq('Chrome')
    end

    it "returns nil if cannot find headers" do
      json = "{\"server_name\":\"sergiu-Lenovo-IdeaPad-Y510P\",\"modules\":{\"rake\":\"10.4.2\",\"i18n\":\"0.7.0\",\"json\":\"1.8.3\",\"minitest\":\"5.8.2\",\"thread_safe\":\"0.3.5\",\"tzinfo\":\"1.2.2\",\"activesupport\":\"4.2.1\",\"builder\":\"3.2.2\",\"erubis\":\"2.7.0\",\"mini_portile\":\"0.6.2\",\"nokogiri\":\"1.6.6.2\",\"rails-deprecated_sanitizer\":\"1.0.3\",\"rails-dom-testing\":\"1.0.7\",\"loofah\":\"2.0.3\",\"rails-html-sanitizer\":\"1.0.2\",\"actionview\":\"4.2.1\",\"rack\":\"1.6.4\",\"rack-test\":\"0.6.3\",\"actionpack\":\"4.2.1\",\"globalid\":\"0.3.6\",\"activejob\":\"4.2.1\",\"mime-types\":\"2.6.2\",\"mail\":\"2.6.3\",\"actionmailer\":\"4.2.1\",\"activemodel\":\"4.2.1\",\"arel\":\"6.0.3\",\"activerecord\":\"4.2.1\",\"debug_inspector\":\"0.0.2\",\"binding_of_caller\":\"0.7.2\",\"bundler\":\"1.11.2\",\"coderay\":\"1.1.0\",\"coffee-script-source\":\"1.10.0\",\"execjs\":\"2.6.0\",\"coffee-script\":\"2.4.1\",\"thor\":\"0.19.1\",\"railties\":\"4.2.1\",\"coffee-rails\":\"4.1.0\",\"multipart-post\":\"2.0.0\",\"faraday\":\"0.9.2\",\"multi_json\":\"1.11.2\",\"jbuilder\":\"2.3.2\",\"jquery-rails\":\"4.0.5\",\"method_source\":\"0.8.2\",\"slop\":\"3.6.0\",\"pry\":\"0.10.3\",\"sprockets\":\"3.4.0\",\"sprockets-rails\":\"2.3.3\",\"rails\":\"4.2.1\",\"rdoc\":\"4.2.0\",\"sass\":\"3.4.19\",\"tilt\":\"2.0.1\",\"sass-rails\":\"5.0.4\",\"sdoc\":\"0.4.1\",\"sentry-raven\":\"0.15.2\",\"spring\":\"1.4.1\",\"sqlite3\":\"1.3.11\",\"turbolinks\":\"2.5.3\",\"uglifier\":\"2.7.2\",\"web-console\":\"2.2.1\"},\"extra\":{},\"tags\":{},\"errors\":[{\"type\":\"invalid_data\",\"name\":\"timestamp\",\"value\":\"2016-02-15T06:01:29\"}],\"interfaces\":{\"exception\":{\"values\":[{\"type\":\"ZeroDivisionError\",\"value\":\"\\\"divided by 0\\\"\",\"module\":\"\",\"stacktrace\":{\"frames\":[{\"abs_path\":\"/home/sergiu/.rvm/rubies/ruby-2.2.2/lib/ruby/2.2.0/webrick/server.rb\",\"filename\":\"webrick/server.rb\",\"function\":\"block in start_thread\",\"context_line\":\"          block ? block.call(sock) : run(sock)\\n\",\"pre_context\":[\"module ActionController\\n\",\"  module ImplicitRender\\n\",\"    def send_action(method, *args)\\n\"],\"post_context\":[\"      default_render unless performed?\\n\",\"      ret\\n\",\"    end\\n\"],\"lineno\":4},{\"abs_path\":\"/home/sergiu/ravenapp/app/controllers/home_controller.rb\",\"filename\":\"app/controllers/home_controller.rb\",\"function\":\"index\",\"context_line\":\"    1/0\\n\",\"pre_context\":[\"  # Prevent CSRF attacks by raising an exception.\\n\",\"  # For APIs, you may want to use :null_session instead.\\n\",\"  def index\\n\"],\"post_context\":[\"  end\\n\",\"end\\n\",\"\"],\"lineno\":5},{\"abs_path\":\"/home/sergiu/ravenapp/app/controllers/home_controller.rb\",\"filename\":\"app/controllers/home_controller.rb\",\"function\":\"/\",\"context_line\":\"    1/0\\n\",\"pre_context\":[\"  # Prevent CSRF attacks by raising an exception.\\n\",\"  # For APIs, you may want to use :null_session instead.\\n\",\"  def index\\n\"],\"post_context\":[\"  end\\n\",\"end\\n\",\"\"],\"lineno\":5}],\"frames_omitted\":null,\"has_frames\":true}}],\"exc_omitted\":null}}}"
      issue.update_attributes(data: json)
      expect(issue.user_agent).to be_nil
    end

    it "responds with a message if it cannot parse data" do
      issue.update_attributes(data: ("something to_json").to_json)
      expect(issue.user_agent).to eq('Could not parse data!')
    end
  end

end




