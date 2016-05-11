require 'rails_helper'
include ErrorStore::Utils

RSpec.describe ErrorStore::Interfaces::Sdk do
  # let(:website) { create :website }
  # let(:post_request) { post_error_request(web_response_factory('ruby_exception'), website) }

  let(:post_request) {
    {:exception=>
      {:values=>
        [{:stacktrace=>
           {:frames=>
             [{:function=>"<module>",
               :abs_path=>"./testing.py",
               :pre_context=>
                ["import pdb, raven, os",
                 "",
                 "client = raven.Client(dsn= 'http://01823eb4e74f172b7df08d682f36eedc:39fc7ea388a3be5e13f459d942ac94b1@localhost:3000/39fc7ea388a3be5e13f459d942ac94b1')",
                 "",
                 "try:"],
               :post_context=>["except ZeroDivisionError:", "  client.captureException()"],
               :vars=>
                {:__builtins__=>"<module '__builtin__' (built-in)>",
                 :__file__=>"'./testing.py'",
                 :__package__=>nil,
                 :client=>"<raven.base.Client object at 0x7fdfcb66ad90>",
                 :__doc__=>nil,
                 :__name__=>"'__main__'",
                 :os=>"<module 'os' from '/usr/lib/python2.7/os.pyc'>",
                 :pdb=>"<module 'pdb' from '/usr/lib/python2.7/pdb.py'>",
                 :raven=>
                  "<module 'raven' from '/home/hyperionel/.local/lib/python2.7/site-packages/raven/__init__.pyc'>"},
               :module=>"__main__",
               :filename=>"testing.py",
               :lineno=>8,
               :context_line=>"  1 / 0"}]},
          :type=>"ZeroDivisionError",
          :module=>"exceptions",
          :value=>"integer division or modulo by zero"}]},
      :culprit=>"__main__ in <module>",
      :server_name=>"hyperionel",
      :extra=>{:"sys.argv"=>["'./testing.py'"]},
      :event_id=>"bb31075106d043f9a78a28772a0672fc",
      :timestamp=>1462964330,
      :level=>40,
      :modules=>{:python=>"2.7.10"},
      :time_spent=>nil,
      :platform=>"python",
      :message=>"ZeroDivisionError: integer division or modulo by zero",
      :tags=>{},
      :sdk=>{:version=>"5.15.0", :name=>"raven-python"},
      :website=>1,
      :errors=>[],
      :interfaces=>{},
      :site=>nil,
      :checksum=>nil}
  }

  let(:post_data) { post_request[:sdk] }
  let(:sdk) { ErrorStore::Interfaces::Sdk.new(post_data) }


  it 'it returns Sdk for display_name' do
    expect( ErrorStore::Interfaces::Sdk.display_name ).to eq("Sdk")
  end

  it 'it returns type :sdk' do
    expect( sdk.type ).to eq(:sdk)
  end

  describe 'sanitize_data' do
    subject { sdk.sanitize_data(post_data) }
    context 'raises ValidationError' do
      it 'raises No name value error' do
        post_data.delete :name
        expect { subject }.to raise_exception(ErrorStore::ValidationError, "No 'name' value")
      end

      it 'raises No version value error' do
        post_data.delete :version
        expect { subject }.to raise_exception(ErrorStore::ValidationError, "No 'version' value")
      end
    end

    it 'assigns the trimmed version and name to self._data' do
      expect( subject._data ).to eq( { name: trim(post_data[:name]), version: trim(post_data[:version]) } )
    end
  end
end