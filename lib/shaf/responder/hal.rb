module Shaf
  module Responder
    class Hal < Base
      mime_type :hal, 'application/hal+json'
      use_as_default!

      def self.lookup_rel(rel, response)
        return [] unless response.serialized
        # FIXME: find a way to get the hash from HALPresenter and make the
        # generate json in the #body (using Oj)
        hal = JSON.parse(response.serialized, symbolize_names: true)

        links = hal.dig(:_links, rel.to_sym)
        return [] unless links

        links = [links] unless links.is_a? Array
        links.map do |link|
          [link[:href], 'object']
        end
      end

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
