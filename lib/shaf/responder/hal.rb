require 'shaf/responder/hal_serializable'

module Shaf
  module Responder
    class Hal < Base
      include HalSerializable

      use_as_default!
      mime_type :hal, 'application/hal+json'

      def body
        @body ||= JSON.generate(serialized_hash)
      end

      private

      def mime_type
        type = super
        type = "#{type};profile=#{profile}" if profile
        type
      end

      def profile
        return unless serializer

        @profile ||= options[:profile] || serializer.semantic_profile
      end
    end
  end
end
