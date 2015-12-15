module ErrorStore
  class ErrorManager
    def initialize(data, version: '5')
      @data     = data
      @version  = version
    end

    def normalize()

      data = @data

      data[:level] = DEFAULT_LOG_LEVEL unless data[:level].is_a?(String) || LOG_LEVELS.include?(data[:level])

      if !data[:logger]
        data[:logger] = DEFAULT_LOGGER_NAME
      else
        logger = trim(data[:logger].strip(), max_size: 64)
        # TODO check this
        if TagKey.is_valid_key(logger)
          data[:logger] = logger
        else
          data[:logger] = DEFAULT_LOGGER_NAME
        end
      end

      data[:platform] = trim(data[:platform], max_size: 64) if !data[:platform]

      timestamp = data[:timestamp]
      timestamp = Time.now.utc unless timestamp



      data[:timestamp] = timestamp

      data[:event_id] = SecureRandom.hex() unless data[:event_id]

      data[:message]     = data.fetch(:message, '')
      data[:culprit]     = data.fetch(:culprit, nil)
      data[:time_spent]  = data.fetch(:time_spent, nil)
      data[:server_name] = data.fetch(:server_name, nil)
      data[:site]        = data.fetch(:site, nil)
      data[:checksum]    = data.fetch(:checksum, nil)
      data[:fingerprint] = data.fetch(:fingerprint, nil)
      data[:platform]    = data.fetch(:platform, nil)
      data[:environment] = data.fetch(:environment, nil)
      data[:extra]       = data.fetch(:extra, {})
      data[:errors]      = data.fetch(:errors, [])



      data[:extra] = {} unless data[:extra].is_a?(Hash)

      trim_hash(data[:extra], max_size: ErrorStore::MAX_VARIABLE_SIZE)

      data.keys.each do |key|
        next if CLIENT_RESERVED_ATTRS.include?(key)
        value = data.delete(key)

        begin
          interface = get_interface(key)
        rescue ErrorStore::InvalidAttribute => e
          next
        end

        begin
          interface.sanitize_data(value)
          data[interface.type()] = interface.to_json()
        rescue Exception => e
          pass #???
        end
      end

      data[:version] = @version



      data[:time_spent] = data[:time_spent].to_i if data[:time_spent]
      data[:culprit] = trim(data[:culprit], max_size: MAX_CULPRIT_LENGTH) if data[:culprit]
      data[:message] = trim(data[:message], max_size: MAX_MESSAGE_LENGTH) if data[:message]
      return data
    end
  end
end