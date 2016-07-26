require 'rails_helper'

RSpec.describe ErrorStore::Interfaces::Breadcrumbs do
  let(:website) { create :website }

  let(:get_request) { get_error_request(web_response_factory('js_exception'), website) }
  let(:error) { ErrorStore::Error.new(request: get_request) }
  let(:breadcrumbs) { ErrorStore::Interfaces::Breadcrumbs.new(error) }
  let(:time_now) { 'Fri, 24 Jun 2016 08:49:35 +0000'.to_time }
  let(:breadcrumbs_data) {
    {"values":[
        {
          "timestamp": time_now.to_f,
          "category": "ui.click",
          "message": " > html.gr__192_168_2_2",
          "event_id": "f22f7d9ec1b348a1aa2688c09533814c"
        }
      ]}
    }

  it 'it returns Breadcrumbs for display_name' do
    expect( ErrorStore::Interfaces::Breadcrumbs.display_name ).to eq("Breadcrumbs")
  end
  it 'it returns type :breadcrumbs' do
    expect( breadcrumbs.type ).to eq(:breadcrumbs)
  end

  describe 'sanitize_data' do
    subject { Timecop.freeze(time_now.to_time) do breadcrumbs.sanitize_data(breadcrumbs_data) end }

    it 'sets _data to be a hash with values and array of data' do
      expect( subject._data ).to be_kind_of(Hash)
      expect( subject._data[:values] ).to be_kind_of(Array)
    end

    it 'calls sanitize_data' do
      expect_any_instance_of(ErrorStore::Interfaces::Breadcrumbs).to receive(:sanitize_data).with(breadcrumbs_data)
      subject
    end
  end

  describe 'normalize_crumb' do
    let(:crumb) { breadcrumbs_data[:values].first }
    subject { breadcrumbs.normalize_crumb(crumb) }
    it 'calls normalize_crumb' do
      expect_any_instance_of(ErrorStore::Interfaces::Breadcrumbs).to receive(:normalize_crumb).with(crumb)
      breadcrumbs.sanitize_data(breadcrumbs_data)
    end

    it 'returns type' do
      crumb[:type] = 'test'
      Timecop.freeze(time_now.to_time) do
        expect(breadcrumbs.normalize_crumb(crumb)[:type]).to eq("test")
      end
    end

    it "returns 'default' type if type is not present " do
      Timecop.freeze(time_now.to_time) do
        expect(subject[:type]).to eq("default")
      end
    end

    it 'has level' do
      crumb1 = crumb[:level] = 'error'
      Timecop.freeze(time_now.to_time) do
        expect(breadcrumbs.normalize_crumb(crumb)[:level]).to eq('error')
      end
    end

    it 'processes timestamp' do
      Timecop.freeze(time_now.to_time) do
        expect(crumb[:timestamp].is_a? Float).to eq(true)
        expect( subject[:timestamp].is_a? Integer ).to eq(true)
      end
    end

    it 'trims message' do
      crumb[:message] = web_response_factory('ruby_exception')
      Timecop.freeze(time_now.to_time) do
        expect(breadcrumbs.normalize_crumb(crumb)[:message].length).to eq(4096)
      end
    end

    it 'trims category' do
      crumb[:category] = web_response_factory('ruby_exception')
      Timecop.freeze(time_now.to_time) do
        expect(breadcrumbs.normalize_crumb(crumb)[:category].length).to eq(256)
      end
    end

    it 'has event_id' do
      Timecop.freeze(time_now.to_time) do
        expect(breadcrumbs.normalize_crumb(crumb)[:event_id]).to eq(crumb[:event_id])
      end
    end

    it 'trims data if present' do
      crumb[:data] = web_response_factory('ruby_exception')
      Timecop.freeze(time_now.to_time) do
        expect(breadcrumbs.normalize_crumb(crumb)[:data].length).to eq(4096)
      end
    end

    it 'returns a hash' do
      Timecop.freeze(time_now.to_time) do
        expect( subject ).to be_kind_of(Hash)
      end
    end
  end
end