module ErrorStore::Interfaces
  class Query < ErrorStore::BaseInterface
    def self.display_name
      'Query'
    end

    def type
      :query
    end
  end
end
