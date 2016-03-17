require 'rails_helper'

RSpec.describe ErrorStore::Interfaces::Exception do
  let(:website) { create :website }
  let(:group) { create :grouped_issue, website: website }
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_error) { create :issue, subscriber: subscriber, group: group, event_id: '8af060b2986f5914764d49b7f39b036c' }

  let(:data) { JSON.parse(issue_error.data, symbolize_names: true) }
  let(:error) { ErrorStore::Error.new(request: post_error_request(web_response_factory('ruby_exception'), website), issue: issue_error) }
  let(:exception) { ErrorStore::Interfaces::Exception.new(error) }

  it 'it returns Exception for display_name' do
    expect( ErrorStore::Interfaces::Exception.display_name ).to eq("Exception")
  end
  it 'it returns type :exception' do
    expect( exception.type ).to eq(:exception)
  end

  describe 'sanitize_data' do
    it 'sets _data to be a hash with values and array of data' do
      expect( exception.sanitize_data(data[:interfaces][:exception]).instance_variable_get(:@_data) ).to be_kind_of(Hash)
      expect( exception.sanitize_data(data[:interfaces][:exception]).instance_variable_get(:@_data)[:values] ).to be_kind_of(Array)
    end
    it 'raises ValidationError if no data[:values]' do
      data[:interfaces][:exception] = {}
      expect{ exception.sanitize_data(data[:interfaces][:exception]).instance_variable_get(:@_data) }.to raise_exception(ErrorStore::ValidationError)
    end
    it 'trims values to not go with too many exceptions' do
      hash_30 = {}
      hash_30[:values] = [ {:abs_path=>"/home/sergiu/.rvm/rubies/ruby-2.2.2/lib/ruby/2.2.0/webrick/server.rb"},
                  {:filename=>"webrick/server.rb"},
                  {:function=>"block in start_thread"},
                  {:context_line=>"          block ? block.call(sock) : run(sock)\n"},
                  {:pre_context=>["module ActionController\n", "  module ImplicitRender\n", "    def send_action(method, *args)\n"]},
                  {:post_context=>["      default_render unless performed?\n", "      ret\n", "    end\n"]},
                  {:lineno=>4},
                  {:abs_path=>"/home/sergiu/ravenapp/app/controllers/home_controller.rb"},
                  {:filename=>"app/controllers/home_controller.rb"},
                  {:function=>"index"},
                  {:context_line=>"    1/0\n"},
                  {:pre_context=>["  # Prevent CSRF attacks by raising an exception.\n", "  # For APIs, you may want to use :null_session instead.\n", "  def index\n"]},
                  {:post_context=>["  end\n", "end\n", ""]},
                  {:lineno=>5},
                  {:abs_path=>"/home/sergiu/ravenapp/app/controllers/home_controller.rb"},
                  {:filename=>"app/controllers/home_controller.rb"},
                  {:function=>"/"},
                  {:context_line=>"    1/0\n"},
                  {:pre_context=>["  # Prevent CSRF attacks by raising an exception.\n", "  # For APIs, you may want to use :null_session instead.\n", "  def index\n"]},
                  {:post_context=>["  end\n", "end\n", ""]},
                  {:lineno=>5},
                  {:post_context=>["  end\n", "end\n", ""]},
                  {:lineno=>5},
                  {:abs_path=>"/home/sergiu/ravenapp/app/controllers/home_controller.rb"},
                  {:filename=>"app/controllers/home_controller.rb"},
                  {:function=>"/"},
                  {:context_line=>"    1/0\n"},
                  {:pre_context=>["  # Prevent CSRF attacks by raising an exception.\n", "  # For APIs, you may want to use :null_session instead.\n", "  def index\n"]},
                  {:post_context=>["  end\n", "end\n", ""]},
                  {:lineno=>5}
                ]
      expect( exception.trim_exceptions(hash_30) ).to eq(12..18)
    end
    it 'checks [:values][:stacktrace] and calls SingleException with has_frames' do
      expect_any_instance_of(ErrorStore::Interfaces::SingleException).to receive(:sanitize_data).with(data[:interfaces][:exception][:values][0], true)
      exception.sanitize_data(data[:interfaces][:exception])
    end
    it 'checks [:values][:stacktrace] and calls SingleException without has_frames' do
      data[:interfaces][:exception][:values][0][:stacktrace][:frames] = []
      expect_any_instance_of(ErrorStore::Interfaces::SingleException).to receive(:sanitize_data).with(data[:interfaces][:exception][:values][0], false)
      exception.sanitize_data(data[:interfaces][:exception])
    end
    # it 'sets _data[:values] to eq SingleExceptions' do
    #   expect( exception.sanitize_data(data[:interfaces][:exception]).instance_variable_get(:@_data)[:values] ).to eq(ErrorStore::Interfaces::SingleException.new(error).sanitize_data(data[:interfaces][:exception][:values][0]))
    # end
    it 'raises ValidationError if data[:exc_omitted].length is equal to 2' do
      data[:interfaces][:exception][:exc_omitted] = { :a => 'a', :b => 'b', :c => 'c' }
      expect{ exception.sanitize_data(data[:interfaces][:exception])}.to raise_exception(ErrorStore::ValidationError)
    end
    it 'returns Exception instance'
  end

  describe 'to_json' do
  end

  describe 'data_has_frames' do
    it 'returns true if it has frames' do
      expect( exception.data_has_frames(data[:interfaces][:exception]) ).to be(true)
    end
    it 'returns false if it does not have frames' do
      data[:interfaces][:exception][:values][0][:stacktrace][:frames] = []
      expect( exception.data_has_frames(data[:interfaces][:exception]) ).to be(false)
    end
  end

  describe 'trim_exceptions' do
    it 'trims exceptions to max' do
      ##TODO
      # hash_30 = {}
      # hash_30[:values] = [ {:abs_path=>"/home/sergiu/.rvm/rubies/ruby-2.2.2/lib/ruby/2.2.0/webrick/server.rb"},
      #             {:filename=>"webrick/server.rb"},
      #             {:function=>"block in start_thread"},
      #             {:context_line=>"          block ? block.call(sock) : run(sock)\n"},
      #             {:pre_context=>["module ActionController\n", "  module ImplicitRender\n", "    def send_action(method, *args)\n"]},
      #             {:post_context=>["      default_render unless performed?\n", "      ret\n", "    end\n"]},
      #             {:lineno=>4},
      #             {:abs_path=>"/home/sergiu/ravenapp/app/controllers/home_controller.rb"},
      #             {:filename=>"app/controllers/home_controller.rb"},
      #             {:function=>"index"},
      #             {:context_line=>"    1/0\n"},
      #             {:pre_context=>["  # Prevent CSRF attacks by raising an exception.\n", "  # For APIs, you may want to use :null_session instead.\n", "  def index\n"]},
      #             {:post_context=>["  end\n", "end\n", ""]},
      #             {:lineno=>5},
      #             {:abs_path=>"/home/sergiu/ravenapp/app/controllers/home_controller.rb"},
      #             {:filename=>"app/controllers/home_controller.rb"},
      #             {:function=>"/"},
      #             {:context_line=>"    1/0\n"},
      #             {:pre_context=>["  # Prevent CSRF attacks by raising an exception.\n", "  # For APIs, you may want to use :null_session instead.\n", "  def index\n"]},
      #             {:post_context=>["  end\n", "end\n", ""]},
      #             {:lineno=>5},
      #             {:post_context=>["  end\n", "end\n", ""]},
      #             {:lineno=>5},
      #             {:abs_path=>"/home/sergiu/ravenapp/app/controllers/home_controller.rb"},
      #             {:filename=>"app/controllers/home_controller.rb"},
      #             {:function=>"/"},
      #             {:context_line=>"    1/0\n"},
      #             {:pre_context=>["  # Prevent CSRF attacks by raising an exception.\n", "  # For APIs, you may want to use :null_session instead.\n", "  def index\n"]},
      #             {:post_context=>["  end\n", "end\n", ""]},
      #             {:lineno=>5}
      #           ]
      # expect( exception.trim_exceptions(hash_30).length ).to eq(25)
    end
  end

  describe 'get_hash' do
    it 'returns system_hash'
    it 'returns system_hash'
  end
end
