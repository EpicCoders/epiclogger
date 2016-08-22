class AggregatesWorker
  include Sidekiq::Worker
  def perform(issue_id)
    record = Issue.find(issue_id)
    ErrorStore::Aggregates.new(record).handle_aggregates
  end
end