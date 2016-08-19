module ErrorStore
  class Aggregates < StoreError

    def initialize(issue)
      @issue  = issue
    end

    ATTRIBUTES = [
      'message',
      'subscriber',
      'browser',
      'browser_platform',
      'user',
      'url',
      'version',
      'file',
      'server_hostnames',
      'notifier_remote_address'
    ]

    def handle_aggregates
      ATTRIBUTES.each do |attribute|
        unless (data = @issue.public_send(attribute)).nil?
          record = @issue.group.aggregates.find_or_create_by(name: attribute)
          data = data.name if attribute == 'subscriber'
          if record.value[data].nil?
            record.value[data] = { :count => 1, :created_at => @issue.created_at, :updated_at => @issue.updated_at }
          else
            record.value[data]['count'] += 1
            record.value[data]['updated_at'] = @issue.updated_at
          end
          record.save
        end
      end
    end
  end
end