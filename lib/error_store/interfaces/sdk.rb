module ErrorStore::Interfaces
  class Sdk < ErrorStore::BaseInterface

    def self.display_name
      'Sdk'
    end

    def type
      :sdk
    end

    def sanitize_data (data)
      raise ErrorStore::ValidationError.new(self), "No 'name' value" if !data[:name].present?
      raise ErrorStore::ValidationError.new(self), "No 'version' value" if !data[:version].present?
      self._data =
      {
        name: trim(data[:name]),
        version: trim(data[:version])
      }
      self
    end
  end
end