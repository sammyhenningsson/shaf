module Shaf
  module Responder
    class Hal < Base
      mime_type :hal, 'application/hal+json'
      use_as_default!

      def body
        serialize
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
