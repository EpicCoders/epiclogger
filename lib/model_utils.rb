module ModelUtils
  module URIField
    extend ActiveSupport::Concern

    included do
      def self.ensure_valid_protocol(*fields, default_protocol: "http", protocols_matcher: "https?")
        fields.each do |field|
          define_method "#{field}=" do |new_uri|
            if new_uri.present? and not new_uri =~ /^#{protocols_matcher}:\/\//
              new_uri = "#{default_protocol}://#{new_uri}"
            end
            super(new_uri)
          end
        end
      end
    end
  end
end