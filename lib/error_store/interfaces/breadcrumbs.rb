module ErrorStore::Interfaces
  class Breadcrumbs < ErrorStore::BaseInterface
    def self.display_name
      'Breadcrumbs'
    end

    def type
      :breadcrumbs
    end

    def sanitize_data(data)
      values = []
      data[:values].each do |value|
        values << Breadcrumbs.new(@error).normalize_crumb(value)
      end
      self._data[:values] = values

      self
    end

    def normalize_crumb(crumb)
      type = crumb[:type] || 'default'
      timestamp = @error.process_timestamp!(crumb)[:timestamp]

      hash =
      {
        type: type,
        timestamp: timestamp
      }

      level = crumb[:level]
      unless level.blank? || level == 'info'
        hash[:level] = level
      end

      message = crumb[:message]
      unless message.blank?
         hash[:message] = trim(message, max_size: 4096)
      end

      category = crumb[:category]
      unless category.blank?
         hash[:category] = trim(category, max_size: 256)
      end

      event_id = crumb[:event_id]
      unless event_id.blank?
         hash[:event_id] = event_id
      end

      if crumb[:data].present?
        hash[:data] = trim(crumb[:data], max_size: 4096)
      end

      return hash
    end
  end
end