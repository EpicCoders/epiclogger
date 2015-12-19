module ErrorStore::Interfaces
  class User < ErrorStore::BaseInterface
    def self.display_name
      'User'
    end

    def type
      :user
    end
  end
end
