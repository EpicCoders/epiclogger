module ErrorStore
  class Manager
    attr_accessor :data, :current_release

    def initialize(data, version: '5')
      @data     = data
      @version  = version
    end

    # 4. store the error after validating the error data
    def store_error
      website_id = @data.delete(:website)
      website = Website.find(website_id)

      data = @data.clone

      # First we pull out our top-level (non-data attr)
      event_id      = data.delete(:event_id)
      message       = data.delete(:message)
      level         = data.delete(:level)

      culprit       = data.delete(:culprit)
      time_spent    = data.delete(:time_spent)
      logger_name   = data.delete(:logger)
      checksum      = data.delete(:checksum)
      fingerprint   = data.delete(:fingerprint)
      platform      = data.delete(:platform)

      culprit = generate_culprit(data) if culprit.blank?
      release = check_release(data.delete(:release), website)

      # TODO implement tags
      # tags = data[:tags] || []
      # tags['level'] = LOG_LEVELS[level]
      # tags['logger'] = logger_name
      # tags['server_name'] = server_name
      # tags['site'] = site
      # tags['release'] = release
      # tags['environment'] = environment
      date = Time.zone.at(data.delete(:timestamp))

      issue = Issue.new(
        website: website,
        event_id: event_id,
        data: data.to_json,
        time_spent: time_spent,
        datetime: date,
        message: message,
        platform: platform
      )
      issue.subscriber = _get_subscriber(website, data)

      data[:fingerprint] = fingerprint || ['{{ default }}']

      hash = if !fingerprint.nil?
               md5_from_hash(get_hashes_from_fingerprint(issue, fingerprint))
             elsif !checksum.nil?
               checksum
             else
               md5_from_hash(get_hash_for_issue(issue))
             end

      group_params = {
        message: message,
        platform: platform,
        culprit: culprit,
        issue_logger: logger_name,
        level: level,
        last_seen: date,
        first_seen: date,
        time_spent_total: time_spent || 0,
        time_spent_count: time_spent && 1 || 0,
        release_id: release.id
      }

      group, is_sample = _save_aggregate(issue, hash, **group_params)

      issue.group = group
      issue.group_id = group.id

      # save the issue unless its been sampled
      db_store(:issue) { issue.save } unless is_sample

      issue
    end

    #match a release
    def check_release(slug_commit, website)
      last_release = website.releases.last
      unless slug_commit.nil?
        current_release = Release.create_with(website_id: website.id).find_or_create_by(version: slug_commit)
        unless last_release.nil? || last_release.version == current_release.version
          last_release.grouped_issues.update_all(:status => 2, :release_id => current_release.id )
        end
      end
      release = current_release unless slug_commit.nil?
      release = last_release if slug_commit.nil?

      return release
    end

    # here we save the grouped issue with all details
    def _save_aggregate(issue, hash, **args)
      website = issue.website
      # attempt to find a matching hash
      group = GroupedIssue.find_by(checksum: hash)
      existing_group_id = group.try(:id)

      group_is_new = if existing_group_id.nil?
                       # args[:score]  = ScoreClause.calculate(1, args[:last_seen])
                       args[:checksum] = hash
                       group = GroupedIssue.create(website: website, **args)
                       true
                     else
                       false
                     end

      # call this before aggregate so last_seen doesn't get changed
      can_sample = should_sample(issue.datetime, group.last_seen, group.times_seen)

      is_regression = if group_is_new
                        false
                      else
                        _process_existing_aggregate(group, issue, args)
                      end

      # Determine if we've sampled enough data to store this issue
      is_sample = if group_is_new || is_regression
                    false
                  else
                    can_sample
                  end

      return group, is_sample
    end

    def should_sample(current_datetime, last_seen, times_seen)
      silence_timedelta = current_datetime - last_seen
      silence = (silence_timedelta / 1.day) * 86_400 + (silence_timedelta / 1.second)

      return false if times_seen % count_limit(times_seen) == 0
      return false if times_seen % time_limit(silence) == 0
      true
    end

    def time_limit(silence)
      ErrorStore::SAMPLE_TIMES.map do |interval, sample_rate|
        return sample_rate if silence >= interval
      end
      ErrorStore::MAX_SAMPLE_TIME
    end

    def count_limit(count)
      # ~ 150 * ((log(n) - 1.5) ^ 2 - 0.25)
      ErrorStore::SAMPLE_RATES.map do |amount, sample_rate|
        return sample_rate if count <= amount
      end
      ErrorStore::MAX_SAMPLE_RATE
    end

    def _process_existing_aggregate(group, issue, data)
      date = [issue.datetime, group.last_seen].max
      extra = {
        last_seen: date,
        # score: ScoreClause(group),
      }
      extra[:message] = issue.message if issue.message && issue.message != group.message
      extra[:level] = data[:level] if group.level != data[:level]
      extra[:culprit] = data[:culprit] if group.culprit != data[:culprit]

      is_regression = _handle_regression(group, issue)

      group.last_seen = extra[:last_seen]

      update_args = { times_seen: 1 }
      if issue.time_spent
        update_args[:time_spent_total] = issue.time_spent
        update_args[:time_spent_count] = 1
      end
      # we update the counters of grouped issue like times_seen
      # and/or time_spent_total & time_spent_count
      GroupedIssue.update_counters(group.id, update_args)
      group.update_attributes(extra) # we set the new attributes if they changed

      is_regression
    end

    def _handle_regression(group, issue)
      return unless group.resolved?

      # we now think its a regression so we are updating the status of the grouped issue
      last_release = group.website.releases.last
      date = [issue.datetime, group.last_seen].max
      statuses = [GroupedIssue::RESOLVED, GroupedIssue::UNRESOLVED]
      is_regression = GroupedIssue.where(id: group.id, status: statuses)
                      .where('active_at < ?', date - 5.seconds)
                      .update_all(active_at: date, last_seen: date, status: GroupedIssue::UNRESOLVED, release_id: last_release.id)

      group.active_at = date
      group.status = :unresolved

      is_regression
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

      culprit.try(:truncate, ErrorStore::MAX_CULPRIT_LENGTH)
    end

    def _get_subscriber(website, data)
      user_data = data[:interfaces][:user]
      return if user_data.blank?

      # Serialization Failure handling
      subscriber = db_store(:subscriber) do
        Subscriber.where(website: website, identity: user_data[:id], email: user_data[:email])
          .first_or_initialize(
            username: user_data[:username],
            ip_address: user_data[:ip_address]
          )
      end

      subscriber
    end

    def get_hash_for_issue(issue)
      get_hash_for_issue_with_reason(issue)[1]
    end

    def get_hash_for_issue_with_reason(issue)
      interfaces = issue.get_interfaces
      interfaces.each do |interface|
        result = interface.get_hash
        next if result.blank?
        return [interface.type, result]
      end
      [:message, [issue.message]]
    end

    def get_hashes_from_fingerprint(issue, fingerprint)
      default_values = ['{{ default }}', '{{default}}']
      if default_values.any? { |i| fingerprint.include?(i) }
        default_hashes = get_hash_for_issue(issue)
        hash_count = default_hashes.length
      else
        hash_count = 1
      end

      hashes = []
      (0..hash_count).each do |i|
        result = []
        fingerprint.each do |bit|
          result << if default_values.include?(bit)
                      default_hashes[i]
                    else
                      bit
                    end
        end
        hashes << result
      end
      hashes
    end

    def md5_from_hash(hash_chunks)
      result = Digest::MD5.new
      hash_chunks.each do |chunk|
        result.update(chunk.to_s)
      end
      result.hexdigest
    end

    def db_store(model)
      retried = false
      begin
        model.to_s.classify.constantize.transaction(isolation: :serializable) do
          yield
        end
      rescue PG::TRSerializationFailure => exception
        if !retried
          retried = true
          retry
        else
          Rails.logger.info('Exception in Manager.db_store')
          Rails.logger.info("Message: #{exception.message}")
          Rails.logger.info("Class: #{exception.class}")
          raise exception
        end
      rescue => exception
        Rails.logger.info('Exception in Manager.db_store')
        Rails.logger.info("Message: #{exception.message}")
        Rails.logger.info("Class: #{exception.class}")
        raise exception
      end
    end
  end
end
