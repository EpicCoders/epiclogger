module ErrorStore::Interfaces
  class User < ErrorStore::BaseInterface
    def self.display_name
      'User'
    end

    def type
      :user
    end

    def sanitize_data(data)
      extra_data = data[:data]
      extra_data = {} unless extra_data.is_a?(Hash)

      ident = trim(data[:id], max_size: 128)

      begin
        email = trim(validate_email(data[:email]), max_size: 128)
      rescue ErrorStore::BadData
        raise ErrorStore::ValidationError.new(self), "Invalid value for 'email'"
      end

      username = trim(data[:username], max_size: 128)

      begin
        ip_address = validate_ip(data[:ip_address])
      rescue ErrorStore::BadData
        raise ErrorStore::ValidationError.new(self), "Invalid value for 'ip_address'"
      end

      self._data = {
        id:         ident,
        email:      email,
        username:   username,
        ip_address: ip_address,
        data:       trim_hash(extra_data)
      }
      self
    end

    def get_hash
      []
    end
  end
end
