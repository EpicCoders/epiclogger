require 'rails_helper'

RSpec.describe ErrorStore::Interfaces::Frame do
  let(:website) { create :website }
  let(:post_request) { post_error_request(web_response_factory('ruby_exception'), website) }
  let(:post_data) { validated_request(post_request)[:interfaces][:exception][:values][0][:stacktrace][:frames][0] }
  let(:frame) { ErrorStore::Interfaces::Frame.new(post_data) }

  it 'it returns Frame for display_name' do
    expect( ErrorStore::Interfaces::Frame.display_name ).to eq("Frame")
  end
  it 'it returns type :frame' do
    expect( frame.type ).to eq(:frame)
  end

  describe 'sanitize_data' do
    subject { frame.sanitize_data(post_data) }
    context 'raises ValidationError' do
      it 'if abs_path is not string' do
        post_data[:abs_path] = {}
        expect{ subject }.to raise_exception(ErrorStore::ValidationError, "Invalid value for 'abs_path'")
      end
      it 'if filename is not string' do
        post_data[:filename] = {}
        expect{ subject }.to raise_exception(ErrorStore::ValidationError, "Invalid value for 'filename'")
      end
      it 'if function is not string' do
        post_data[:function] = {}
        expect{ subject }.to raise_exception(ErrorStore::ValidationError, "Invalid value for 'function'")
      end
      it 'if module is not string' do
        post_data[:module] = {}
        expect{ subject }.to raise_exception(ErrorStore::ValidationError, "Invalid value for 'module'")
      end

      it 'if no filename function or module' do
        post_data.delete :abs_path
        post_data.delete :filename
        post_data.delete :function
        post_data.delete :module
        expect{ subject }.to raise_exception(ErrorStore::ValidationError, "No 'filename' or 'function' or 'module'")
      end
    end

    it 'sets abs_path to filename if empty' do
      post_data.delete :abs_path
      expect( subject._data[:abs_path] ).to eq(post_data[:filename])
    end
    it 'sets filename to abs_path.path if url' do
      post_data[:abs_path] = 'http://content-url/example.com'
      post_data.delete :filename
      expect( subject._data[:filename] ).to eq('/example.com')
    end

    it 'sets function to nil if function equals ?' do
      post_data[:function] = '?'
      expect( subject._data[:function] ).to be_nil
    end

    it 'sets context_locals to hash if array' do
      post_data[:vars] = [["unu", "doi"], ["trei", 4], ["cinci"]]
      expect( subject._data[:vars] ).to eq({'unu'=>'doi', 'trei'=>4, 'cinci'=>nil})
    end

    it 'sets context_locals to empty hash if not Hash' do
      post_data[:vars] = 'some stuff'
      expect( subject._data[:vars] ).to eq({})
    end

    it 'trimps hash of context_locals' do
      post_data[:vars] = generate_array(100)
      expect( subject._data[:vars].length ).to eq(ErrorStore::MAX_HASH_ITEMS)
    end

    it 'sets data to a hash of data[:data]' do
      post_data[:data] = [["lols", 'wess']]
      expect( subject._data[:data] ).to eq({'lols' => 'wess'})
    end

    it 'trims context_line to max_size 256' do
      post_data[:context_line] = 'some text' * 300
      expect( subject._data[:context_line].length ).to be(256)
    end

    it 'sets pre_context elements to empty string instead of nil' do
      post_data[:pre_context] = ['some data', nil]
      expect( subject._data[:pre_context] ).to eq(['some data', ''])
    end
    it 'sets post_context elements to empty string instead of nil' do
      post_data[:post_context] = [nil, 'some data']
      expect( subject._data[:post_context] ).to eq(['', 'some data'])
    end
    it 'sets pre_context and post_context to nil if context_line is blank' do
      post_data.delete :pre_context
      post_data.delete :post_context
      expect( subject._data[:pre_context] ).to be_nil
      expect( subject._data[:post_context] ).to be_nil
    end

    it 'sets lineno to number' do
      post_data[:lineno] = '60'
      expect( subject._data[:lineno] ).to eq(60)
    end
    it 'sets lineno to nil if lower than 0' do
      post_data[:lineno] = -4
      expect( subject._data[:lineno] ).to be_nil
    end

    it 'sets colno to number' do
      post_data[:colno] = '4'
      expect( subject._data[:colno] ).to eq(4)
    end
    it 'returns a Frame instance' do
      expect( subject ).to be_kind_of(ErrorStore::Interfaces::Frame)
    end
  end

  describe 'get_culprit_string' do
    subject { frame.sanitize_data(post_data); frame.get_culprit_string }
    it 'returns culprit with module' do
      post_data[:module] = 'module me'
      expect( subject ).to eq('module me in send_action')
    end
    it 'returns culprit with filename if module blank' do
      expect( subject ).to eq('action_controller/metal/implicit_render.rb in send_action')
    end
    it 'returns function as ? if blank' do
      post_data[:function] = '?' # we set this to ? as sanitize_data will set function to nil
      expect( subject ).to eq('action_controller/metal/implicit_render.rb in ?')
    end
    it 'returns blank string if fileloc blank' do
      post_data.delete :filename
      post_data.delete :abs_path
      expect( subject ).to eq('')
    end
  end

  describe 'get_hash' do
    subject { frame.sanitize_data(post_data); frame.get_hash }
    it 'contains the module' do
      post_data[:module] = 'some_module'
      expect( subject ).to include(post_data[:module])
    end
    it 'has filename' do
      expect( subject ).to include(post_data[:filename])
    end
    it 'has filename without outliers' do
      post_data[:filename] = Digest::MD5.hexdigest("random_string")
      expect( subject ).to include('<version>')
    end
    it 'does not have context_line if context_line nil' do
      post_data[:context_line] = nil
      expect( subject ).not_to include(nil)
    end
    it 'does not have context_line if context_line length > 120' do
      post_data[:context_line] = 'sometext' * 120
      expect( subject ).not_to include(post_data[:context_line])
    end
    it 'does not have context_line if no function and path_url?' do
      post_data[:abs_path] = 'http://content/url/example.com'
      post_data.delete :function
      expect( subject ).not_to include(post_data[:context_line])
    end
    it 'has context_line if function provided' do
      post_data[:function] = 'lambda$ ' + post_data[:function]
      expect( subject ).to include(post_data[:context_line])
    end
    it 'has context_line if no function' do
      post_data.delete :function
      expect( subject ).to include(post_data[:context_line])
    end
    it 'returns output if no !output and !can_use_context' do
      post_data.delete :context_line
      post_data.delete :filename
      expect( subject ).to eq(['/Users/razvanciocanel/.rvm/gems/ruby-<version>/gems/actionpack-<version>/lib/action_controller/metal/implicit_render.rb', 'send_action'])
    end
    it 'has function if function is_unhashable_function' do
      post_data.delete :context_line
      post_data[:function] = 'lambda$'
      expect( subject ).to include('<function>')
    end
    it 'has function if function' do
      post_data.delete :context_line
      expect( subject ).to include(post_data[:function])
    end
    it 'has lineno' do
      post_data[:lineno] = '5'
      post_data.delete :context_line
      post_data.delete :function
      expect( subject ).to include(5)
    end
  end

  describe 'is_unhashable_module' do
    subject { frame.sanitize_data(post_data); frame.is_unhashable_module? }
    it 'returns true if module include Lambda' do
      post_data[:module] = '$$Lambda$ example for module'
      expect( subject ).to be(true)
    end
    it 'returns false if module does not include Lambda' do
      post_data[:module] = 'example for module'
      expect( subject ).to be(false)
    end
  end

  describe 'is_unhashable_function' do
    subject { frame.sanitize_data(post_data); frame.is_unhashable_function? }
    it 'returns true if function starts with lambda' do
      post_data[:function] = 'lambda$ ' + post_data[:function]
      expect( subject ).to be(true)
    end
    it 'returns true if function starts with Anonymous' do
      post_data[:function] = '[Anonymous' + post_data[:function] + ']'
      expect( subject ).to be(true)
    end
    it 'returns false if function does not have lambda or Anonymous' do
      expect( subject ).to be(false)
    end
  end

  describe 'is_caused_by?' do
    subject { frame.sanitize_data(post_data); frame.is_caused_by? }
    it 'returns true if filename starts with Caused by:' do
      post_data[:filename] = 'Caused by: Cristii!'
      expect( subject ).to be(true)
    end
    it 'returns false if filename it does not start with Caused by:' do
      expect( subject ).to be(false)
    end
  end

  describe 'path_url?' do
    subject { frame.sanitize_data(post_data); frame.path_url? }
    it 'returns true if abs_path is an url' do
      post_data[:abs_path] = 'file://home-dir'
      expect( subject ).to be(true)
    end
    it 'returns false if no abs_path' do
      post_data.delete :abs_path
      expect( subject ).to be(false)
    end
    it 'returns false if abs_path is not an url' do
      expect( subject ).to be(false)
    end
  end
end
