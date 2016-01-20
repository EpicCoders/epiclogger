module ErrorStore
  class Manager
    attr_accessor :data

    def initialize(data, version: '5')
      @data     = data
      @version  = version
    end

    # 4. store the error after validating the error data
    def store_error
      # binding.pry
      website_id = @data.delete(:website)
      website = Website.find(website_id)

      data = @data.clone

      # First we pull out our top-level (non-data attr)
      event_id      = data.delete(:event_id)
      message       = data.delete(:message)
      level         = data.delete(:level)

      culprit       = data.delete(:culprit) || nil
      time_spent    = data.delete(:time_spent) || nil
      logger_name   = data.delete(:logger) || nil
      server_name   = data.delete(:server_name) || nil
      site          = data.delete(:site) || nil
      checksum      = data.delete(:checksum) || nil
      fingerprint   = data.delete(:fingerprint) || nil
      platform      = data.delete(:platform) || nil
      release       = data.delete(:release) || nil
      environment   = data.delete(:environment) || nil

      culprit = generate_culprit(data) if culprit.blank?

      # TODO, here the timestamp
      # date = datetime.fromtimestamp(data.pop('timestamp'))
      # date = date.replace(tzinfo=timezone.utc)
      date = data.delete(:timestamp) # ?? not done TODO fix

      issue = Issue.new({
          website: website,
          event_id: event_id,
          data: data.to_json,
          time_spent: time_spent,
          datetime: date,
          message: message,
          platform: platform
      })

      issue_user = _get_subscriber(website, data)

      data[:fingerprint] = fingerprint || ['{{ default }}']
      # binding.pry
      hash = if !fingerprint.nil?
               get_hash_from_fingerprint(issue, fingerprint).map { |h| md5_from_hash(h) }
             elsif !checksum.nil?
               [checksum]
             else
               get_hash_for_issue(issue).map { |h| md5_from_hash(h) }
             end
      # binding.pry

      group_params = {
          message: message,
          platform: platform,
          culprit: culprit,
          issue_logger: logger_name,
          level: level,
          last_seen: date,
          first_seen: date,
          time_spent_total: time_spent || 0,
          time_spent_count: time_spent && 1 || 0
      }

      group, is_new, is_regression, is_sample = _save_aggregate(issue: issue, hash: hash, release: release, **group_params)

      issue.group = group
      issue.group_id = group.id

      # save the issue unless its been sampled
      # binding.pry
      # unless is_sample
        retried = false
        begin
          Issue.transaction(isolation: :serializable) do
            issue.save
          end
        rescue PG::TRSerializationFailure => exception
          if !retried
            retried = true
            retry
          else
            Rails.logger.info('Exception in Error._get_subscriber')
            Rails.logger.info("Message: #{exception.message}")
            Rails.logger.info("Class: #{exception.class}")
            raise exception
          end
        rescue => exception
          Rails.logger.info('Exception in Error._store_error')
          Rails.logger.info("Message: #{exception.message}")
          Rails.logger.info("Class: #{exception.class}")
          raise exception
        end
      # end
      issue
    end

    # here we save the grouped issue with all details
    def _save_aggregate(issue, hash, release, **args)
      website = issue.website
      # attempt to find a matching hash
      group = GroupedIssue.find_by(checksum: hash)
      existing_group_id = group.try(:id)

      if existing_group_id.nil?
        # args[:score]  = ScoreClause.calculate(1, args[:last_seen])
        args[:checksum] = hash
        group_is_new = true
        group = GroupedIssue.create(website: website, **args)
      else
        group_is_new = false
      end

      # XXX(dcramer): it's important this gets called **before** the aggregate
      # is processed as otherwise values like last_seen will get mutated
      can_sample = should_sample(issue.datetime, group.last_seen, group.times_seen)

      if group_is_new
        is_regression = false
      else
        is_regression = _process_existing_aggregate(
          group: group,
          issue: issue,
          data: args,
          release: release
        )
      end

      # Determine if we've sampled enough data to store this issue
      is_sample = if group_is_new || is_regression
                    false
                  else
                    can_sample
                  end

      return group, group_is_new, is_regression, is_sample
    end

    def should_sample(current_datetime, last_seen, times_seen)
      silence_timedelta = current_datetime - last_seen
      silence = silence_timedelta.days * 86400 + silence_timedelta.seconds

      return false if times_seen % count_limit(times_seen) == 0
      return false if times_seen % time_limit(silence) == 0
      true
    end

    def time_limit(silence) # ~ 3600 per hour
      ErrorStore::SENTRY_SAMPLE_TIMES.map do |amount, sample_rate|
        return sample_rate if silence >= amount
      end
      ErrorStore::SENTRY_MAX_SAMPLE_TIME
    end

    def _process_existing_aggregate(group, issue, data, release)
      date = [issue.datetime, group.last_seen].max
      extra = {
          last_seen: date,
          # score: ScoreClause(group),
      }
      extra[:message] = issue.message if issue.message && issue.message != group.message
      extra[:level] = data[:level] if group.level != data[:level]
      extra[:culprit] = data[:culprit] if group.culprit != data[:culprit]
      # TODO, continue here.
      is_regression = _handle_regression(group, issue, release)

      group.last_seen = extra[:last_seen]

      update_args = { times_seen: 1 }
      if issue.time_spent
        update_args[:time_spent_total] = issue.time_spent
        update_args[:time_spent_count] = 1
      end

      is_regression
    end

    def _handle_regression(group, issue, release)
      return unless group.is_resolved?
      # we now think its a regression, rely on the database to validate that
      # no one beat us to this
      date = [issue.datetime, group.last_seen].max
      is_regression = GroupedIssue.where(id: group.id,
                                         status: [
                                                    GroupedIssue.status.find_value(:resolved).value,
                                                    GroupedIssue.status.find_value(:unresolved).value
                                                  ]
                                        )
                                  .update_attributes(active_at: date, last_seen: date, status: :unresolved)

      group.active_at = date
      group.status = :unresolved

      is_regression
    end

    def count_limit(count)
      # TODO: could we do something like num_to_store = max(math.sqrt(100*count)+59, 200) ?
      # ~ 150 * ((log(n) - 1.5) ^ 2 - 0.25)
      ErrorStore::SENTRY_SAMPLE_RATES.map do |amount, sample_rate|
        return sample_rate if count <= amount
      end
      ErrorStore::SENTRY_MAX_SAMPLE_RATE
    end

    def generate_culprit(data)
      culprit = ''

      begin
        stacktraces = data[:interfaces][:exception][:values].map { |e| e[:stacktrace] if e.key?(:stacktrace) }.compact
      rescue
        stacktraces = if data[:interfaces].key?(:stacktrace)
                        [data[:interfaces][:stacktrace]]
                      end
      end

      if stacktraces.nil?
        culprit = data[:interfaces][:http].fetch(:url, '') if data[:interfaces].key?(:http)
      else
        culprit = ErrorStore::Interfaces::Stacktrace.new(self).sanitize_data(stacktraces[-1]).get_culprit_string
      end

      truncate(culprit, ErrorStore::MAX_CULPRIT_LENGTH)
    end

    def _get_subscriber(website, data)
      user_data = data[:interfaces][:user]
      return if user_data.blank?

      subscriber = Subscriber.new(
        website: website,
        identity: user_data[:id],
        email: user_data[:email],
        username: user_data[:username],
        ip_address: user_data[:ip_address]
      )
      # Serialization Failure handling
      retried = false

      begin
        Subscriber.transaction(isolation: :serializable) do
          subscriber.save
        end
      rescue PG::TRSerializationFailure => exception
        if !retried
          retried = true
          retry
        else
          Rails.logger.info('Exception in Error._get_subscriber')
          Rails.logger.info("Message: #{exception.message}")
          Rails.logger.info("Class: #{exception.class}")
          # raise exception
        end
      rescue => exception
        Rails.logger.info('Exception in Error._get_subscriber')
        Rails.logger.info("Message: #{exception.message}")
        Rails.logger.info("Class: #{exception.class}")
        # raise exception
      end

      subscriber
    end

    def get_hash_for_issue(issue)
      # binding.pry
      get_hash_for_issue_with_reason(issue)[1]
    end

    def get_hash_for_issue_with_reason(issue)
      interfaces = issue.get_interfaces
      interfaces.each do |interface|
        result = interface.compute_hashes(issue.platform)
        next unless result
        return [interface.type, result]
      end
      [:message, [issue.message]]
    end

    def get_hashes_from_fingerprint(issue, fingerprint)
      default_values = ['{{ default }}', '{{default}}']
      if default_values.any? { |i| fingerprint.include?(i) }
        default_hashes = get_hashes_for_issue(issue)
        hash_count = default_hashes.length
      else
        hash_count = 1
      end

      hashes = []
      (0..hash_count).each do |i|
        result = []
        fingerprint.each do |bit|
          if default_values.include?(bit)
            result.concat(default_hashes[i])
          else
            result << bit
          end
        end
        hashes << result
      end
      hashes
    end

    def get_hashes_from_fingerprint_with_reason(issue, fingerprint)
      default_values = ['{{ default }}', '{{default}}']
      if default_values.any? { |i| fingerprint.include?(i) }
        default_hashes = get_hashes_for_issue_with_reason(issue)
        hash_count = default_hashes[1].length
      else
        hash_count = 1
      end

      hashes = fingerprint
      (0..hash_count).each do
        fingerprint.each do |bit|
          if default_values.include?(bit)
            hashes[bit].concat(default_hashes)
          else
            hashes[bit] = bit
          end
        end
      end
      hashes.items
    end

    def md5_from_hash(hash_chunks)
      result = Digest::MD5.new
      hash_chunks.each do |chunk|
        result.update(chunk.to_s)
      end
      result.hexdigest
    end
  end
end
