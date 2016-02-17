### Message interface
# - message parameter in data can not be more than 1000 characters long
module ErrorStore::Interfaces
  class Message < ErrorStore::BaseInterface
    def self.display_name
      'Message'
    end

    def type
      :message
    end

    def sanitize_data(data)
      raise ErrorStore::ValidationError.new(self), 'No "message" present' unless data[:message]
      self._data[:message] = trim(data[:message], 2048)
      self._data[:params] = if data[:params]
                              trim(data[:params], 1024)
                            else
                              []
                            end

      self
    end

    def get_hash
      [_data[:message]]
    end
  end
end
