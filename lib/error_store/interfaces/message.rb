module ErrorStore::Interfaces
  class Message < ErrorStore::BaseInterface
    def self.display_name
      'Message'
    end

    def type
      :message
    end
  end
end
