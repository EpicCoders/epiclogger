module TempEnableCache
  def temp_enable_dalli_cache!
    let(:cache){ ActiveSupport::Cache::MemoryStore.new }
    before do
      allow(Rails).to receive(:cache).and_return(cache)
    end
    after do
      allow(Rails).to receive(:cache).and_call_original
    end
  end
end

RSpec.configure do |config|
  config.extend TempEnableCache
end
