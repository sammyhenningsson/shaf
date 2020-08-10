module Shaf
  module Responder
    class Hal < Base
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

      def lookup_rel(rel, response)
        hal = response.serialized_hash
        links = hal&.dig(:_links, rel.to_sym)
        return [] unless links

        links = [links] unless links.is_a? Array
        links.map do |link|
          {
            href: link[:href],
            as: 'fetch',
            crossorigin: 'anonymous'
          }
        end
      end
      private

      def mime_type
        type = super
        type = "#{type};profile=#{profile}" if profile
        type
      end

      def collection?
        !!options.fetch(:collection, false)
      end

      def serializer
        @serializer ||= options[:serializer] || HALPresenter.lookup_presenter(resource)
      end

      def serialized_hash
        return {} unless serializer

        @serialized_hash ||=
          if collection?
            serializer.to_collection(resource, current_user: user, as_hash: true, **options)
          else
            serializer.to_hal(resource, current_user: user, as_hash: true, **options)
          end

        # hal_presenter versions before v1.5.0 does not understand the :as_hash
        # keyword argument and will always return a String from
        # to_hal/to_collection, thus we need to parse it if its a String.
        if @serialized_hash.is_a? String
          @body = @serialized_hash
          @serialized_hash = JSON.parse(@serialized_hash, symbolize_names: true)
        end

        @serialized_hash
      end

      def profile
        @profile ||= options[:profile]
        return unless @profile || serializer

        @profile ||= serializer.semantic_profile
      end

      def generate_json
        # FIXME: change to Oj??
        JSON.generate(serialized_hash)
      end
    end
  end
end
