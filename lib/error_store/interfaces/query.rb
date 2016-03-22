### Query interface
# - the query string with the driver postgresql
module ErrorStore::Interfaces
  class Query < ErrorStore::BaseInterface
    def self.display_name
      'Query'
    end

    def type
      :query
    end

    def sanitize_data(data)
      raise ErrorStore::ValidationError.new(self), 'No "query" present' unless data[:query]
      self._data = {
        query: trim(data[:query], max_size: 1024),
        engine: trim(data[:engine], max_size: 128)
      }
      self
    end

    def get_hash
      [_data[:query]]
    end
  end
end
