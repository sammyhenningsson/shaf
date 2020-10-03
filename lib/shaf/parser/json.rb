module Shaf
  module Parser
    class Json < Base

      mime_type :json, 'application/json'

      def self.can_handle?(request)
        request.content_type&.match? %r{application/(.*\+)?json}
      end

      def call
        @payload ||= parse_json
      end

      private

      def parse_json
        return {} if body.empty?

        JSON.parse(body, symbolize_names: true)
      rescue JSON::ParserError => e
        raise Error, e.message
      end
    end
  end
end
