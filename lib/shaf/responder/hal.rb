require 'shaf/responder/hal_serializable'

module Shaf
  module Responder
    class Hal < Base
      include HalSerializable

      use_as_default!
      mime_type :hal, 'application/hal+json'

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
