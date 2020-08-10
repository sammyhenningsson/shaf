require 'shaf/responder/hal_serializable'

module Shaf
  module Responder
    class Hal < Base
      include HalSerializable

      use_as_default!
      mime_type :hal, 'application/hal+json'

      def self.can_handle?(resource)
        return false if resource.is_a? StandardError

        if resource.respond_to? :<=
          return false if resource <= Shaf::Profile
        end

        true
      end

      def body
        @body ||= generate_json
      end

      private

      def mime_type
        type = super
        type = "#{type};profile=#{profile}" if profile
        type
      end
    end
  end
end
