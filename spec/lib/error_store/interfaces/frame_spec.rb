require 'rails_helper'

RSpec.describe ErrorStore::Interfaces::Frame do
  let(:website) { create :website }
  let(:group) { create :grouped_issue, website: website }
  let(:subscriber) { create :subscriber, website: website }
  let!(:issue_error) { create :issue, subscriber: subscriber, group: group, event_id: '8af060b2986f5914764d49b7f39b036c' }

  let(:request) { post_error_request(website.app_key, website.app_secret, web_response_factory('ruby_exception')) }
  let(:data) { JSON.parse(issue_error.data, symbolize_names: true)[:interfaces][:exception][:values][0][:stacktrace][:frames][0] }
  let(:error) { ErrorStore::Error.new(request: request, issue: issue_error) }
  let(:frame) { ErrorStore::Interfaces::Frame.new(error) }

  it 'it returns Frame for display_name' do
    expect( ErrorStore::Interfaces::Frame.display_name ).to eq("Frame")
  end
  it 'it returns type :frame' do
    expect( frame.type ).to eq(:frame)
  end

  describe 'sanitize_data' do
    context 'raises ValidationError' do
      it 'if abs_path is not string' do
        data[:abs_path] = {}
        expect{ frame.sanitize_data(data) }.to raise_exception(ErrorStore::ValidationError)
      end
      it 'if filename is not string' do
        data[:filename] = {}
        expect{ frame.sanitize_data(data) }.to raise_exception(ErrorStore::ValidationError)
      end
      it 'if function is not string' do
        data[:function] = {}
        expect{ frame.sanitize_data(data) }.to raise_exception(ErrorStore::ValidationError)
      end
      it 'if module is not string' do
        data[:module] = {}
        expect{ frame.sanitize_data(data) }.to raise_exception(ErrorStore::ValidationError)
      end

      it 'if no filename function or errmodule' do
        data.delete :abs_path
        data.delete :filename
        data.delete :function
        expect{ frame.sanitize_data(data) }.to raise_exception(ErrorStore::ValidationError)
      end
    end

    it 'sets abs_path to filename if empty and filename to nil' do
      data.delete :abs_path
      expect( frame.sanitize_data(data).instance_variable_get(:@_data)[:abs_path] ).to eq(data[:filename])
    end
    it 'sets filename to abs_path.path if url' do
      data[:abs_path] = "http://content-url/example.com"
      data.delete :filename
      expect( frame.sanitize_data(data).instance_variable_get(:@_data)[:filename] ).to eq("/example.com")
    end

    it 'sets function to nil if function equals ?' do
      data[:function] = "?"
      expect( frame.sanitize_data(data).instance_variable_get(:@_data)[:function] ).to be_nil
    end

    it 'sets context_locals to hash if array' do
      data[:vars] = [["unu", "doi"], ["trei", 4], ["cinci"]]
      expect( frame.sanitize_data(data).instance_variable_get(:@_data)[:vars] ).to eq({"unu"=>"doi", "trei"=>4, "cinci"=>nil})
    end

    xit 'sets context_locals to empty hash if not Hash'

    # it 'trimps hash of context_locals' do
    #   data[:vars] = {[["unu", "doi"], ["trei", 4], ["cinci"]]}
    #   expect(frame).to receive(:trim).with({"unu"=>"doi", "trei"=>4, "cinci"=>nil}).and_return({"unu"=>"doi", "trei"=>4, "cinci"=>nil})
    #   frame.sanitize_data(data)
    # end

    it 'sets data to a hash of data[:data]' do
      data[:data] = "some data"
      expect( frame.sanitize_data(data).instance_variable_get(:@_data)[:data] ).to eq("some data")
    end

    it 'trims context_line to max_size 256' do
      data[:context_line] = issue_error.data
      expect( frame.sanitize_data(data).instance_variable_get(:@_data)[:context_line].length ).to be(256)
    end

    it 'sets pre_context elements to empty string instead of nil' do
      data[:pre_context] = ["some data", nil]
      expect( frame.sanitize_data(data).instance_variable_get(:@_data)[:pre_context] ).to eq(["some data", ""])
    end
    it 'sets post_context elements to empty string instead of nil' do
      data[:post_context] = [nil, "some data"]
      expect( frame.sanitize_data(data).instance_variable_get(:@_data)[:post_context] ).to eq(["", "some data"])
    end
    it 'sets pre_context and post_context to nil if context_line is blank' do
      data.delete :pre_context
      data.delete :post_context
      expect( frame.sanitize_data(data).instance_variable_get(:@_data)[:pre_context] ).to be_nil
      expect( frame.sanitize_data(data).instance_variable_get(:@_data)[:post_context] ).to be_nil
    end

    it 'sets lineno to number' do
      expect( frame.sanitize_data(data).instance_variable_get(:@_data)[:lineno] ).to eq(data[:lineno])
    end
    it 'sets lineno to nil if lower than 0' do
      data[:lineno] = -4
      expect( frame.sanitize_data(data).instance_variable_get(:@_data)[:lineno] ).to be_nil
      data.delete :lineno
      expect( frame.sanitize_data(data).instance_variable_get(:@_data)[:lineno] ).to be_nil
    end

    it 'sets colno to number' do
      data[:colno] = 4
      expect( frame.sanitize_data(data).instance_variable_get(:@_data)[:lineno] ).to eq(4)
    end
    it 'returns a Frame instance' do
      expect( frame.kind_of?(ErrorStore::Interfaces::Frame) ).to be(true)
    end
  end

  describe 'get_culprit_string' do
    before{ frame._data = data }
    it 'returns culprit with module' do
      frame._data[:module] = "example for module"
      frame._data.delete :filename
      expect( frame.get_culprit_string ).to eq("example for module in block in start_thread")
    end
    it 'returns culprit with filename if module blank' do
      expect( frame.get_culprit_string ).to eq("webrick/server.rb in block in start_thread")
    end
    it 'returns function as ? if blank' do
      frame._data.delete :function
      expect( frame.get_culprit_string ).to eq("webrick/server.rb in ?")
    end
    it 'returns blank string if fileloc blank' do
      frame._data.delete :filename
      expect( frame.get_culprit_string ).to eq("")
    end
  end

  describe 'get_hash' do
    before{ frame._data = data }
    it 'contains the module' do
      frame._data[:module] = "example for module"
      expect( frame.get_hash.include?("example for module") ).to be(true)
    end
    it 'has filename' do
      expect( frame._data.has_key?(:filename) ).to be(true)
    end
    it 'has filename without outliers' do
      frame._data[:filename] = Digest::MD5.hexdigest("random_string")
      expect( frame.get_hash.include?("<version>") ).to be(true)
    end
    it 'does not have context_line if context_line nil' do
      frame._data[:context_line] = nil
      expect( frame.get_hash.include?(frame._data[:context_line]) ).to be(false)
    end
    it 'does not have context_line if context_line length > 120' do
      frame._data[:context_line] = issue_error.data
      expect( frame.get_hash.include?(frame._data[:context_line]) ).to be(false)
    end
    it 'does not have context_line if no function and path_url?' do
      frame._data[:abs_path] = "http://content/url/example.com"
      frame._data.delete :function
      expect( frame.get_hash.include?(frame._data[:context_line]) ).to be(false)
    end
    it 'has context_line if function provided' do
      frame._data[:function] = "lambda$ " + data[:function]
      expect( frame.get_hash.include?(frame._data[:context_line]) ).to be(true)
    end
    it 'has context_line if no function' do
      frame._data.delete :function
      expect( frame.get_hash.include?(frame._data[:context_line]) ).to be(true)
    end
    it 'returns output if no !output and !can_use_context' do
      frame._data.delete :context_line
      frame._data.delete :filename
      expect( frame.get_hash ).to eq(["block"])
    end
    it 'has function if function is_unhashable_function' do
      frame._data.delete :context_line
      frame._data[:function] = "lambda$"
      expect( frame.get_hash.include?("<function>") ).to be(true)
    end
    it 'has function if function' do
      frame._data.delete :context_line
      expect( frame.get_hash.include?("block") ).to be(true)
    end
    it 'has lineno' do
      expect( frame._data.has_key?(:lineno) ).to be(true)
    end
  end

  describe 'is_unhashable_module' do
    before{ frame._data = data }
    it 'returns true if module include Lambda' do
      frame._data[:module] = "$$Lambda$ example for module"
      expect( frame.is_unhashable_module? ).to be(true)
    end
    it 'returns false if module does not include Lambda' do
      frame._data[:module] = "example for module"
      expect( frame.is_unhashable_module? ).to be(false)
    end
  end

  describe 'is_unhashable_function' do
    before{ frame._data = data }
    it 'returns true if function starts with lambda' do
      frame._data[:function] = "lambda$ " + data[:function]
      expect( frame.is_unhashable_function? ).to be(true)
    end
    it 'returns true if function starts with Anonymous' do
      frame._data[:function] = '[Anonymous' + data[:function] + "]"
      expect( frame.is_unhashable_function? ).to be(true)
    end
    it 'returns false if function does not have lambda or Anonymous' do
      expect( frame.is_unhashable_function? ).to be(false)
    end
  end

  describe 'is_caused_by?' do
    before{ frame._data = data }
    it 'returns true if filename starts with Caused by:' do
      frame._data[:filename] = "Caused by: Cristii!"
      expect( frame.is_caused_by? ).to be(true)
    end
    it 'returns false if filename it does not start with Caused by:' do
      expect( frame.is_caused_by? ).to be(false)
    end
  end

  describe 'path_url?' do
    before{ frame._data = data }
    it 'returns true if abs_path is an url' do
      frame._data[:abs_path] = "file://home-dir"
      expect( frame.path_url? ).to be(true)
    end
    it 'returns false if no abs_path' do
      frame._data.delete :abs_path
      expect( frame.path_url? ).to be(false)
    end
    it 'returns false if abs_path is not an url' do
      expect( frame.path_url? ).to be(false)
    end
  end
end
