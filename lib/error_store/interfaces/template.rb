module ErrorStore::Interfaces
  class Template < ErrorStore::BaseInterface
    def self.display_name
      'Template'
    end

    def type
      :template
    end
  end
end
