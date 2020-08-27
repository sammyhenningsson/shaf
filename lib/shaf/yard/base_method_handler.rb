# frozen_string_literal: true

module Shaf
  module Yard
    class BaseMethodHandler < ::YARD::Handlers::Ruby::Base
      namespace_only

      def process
        return unless serializer_namespace

        register object
      end

      def name
        call_params.first.yield_self do |name|
          # remove single colon. Sometimes symbols get the :, (e.g. :self)
          name.sub(/\A:(?!:)/, '')
        end
      end

      def object
        raise NotImplementedError, "#{self} must implement #object"
      end

      def serializer_namespace
        @serializer_namespace ||= YARD::Registry.at ResourceObject.path(namespace)
      end
    end
  end
end
