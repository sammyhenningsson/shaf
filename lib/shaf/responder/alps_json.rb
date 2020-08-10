require 'shaf/alps/json_serializer'

module Shaf
  module Responder
    class AlpsJson < Base
      mime_type :alps_json, 'application/alps+json'

      def self.can_handle?(resource)
        return false unless resource.is_a? Class
        resource <= Shaf::Profile
      end

      def body
        JSON.generate hash
      end

      private

      def hash
        ALPS::JsonSerializer.call(resource)
      end
    end
  end
end

