# frozen_string_literal: true

require 'shaf/yard/base_method_handler'

module Shaf
  module Yard
    # Handles call to Shaf::Serializer::link
    class LinkMethodHandler < BaseMethodHandler
      handles method_call(:link)

      def object
        LinkObject.new(serializer_namespace, name).tap do |link|
          link.dynamic = true
          link.rel = name
          link.curie = curie
        end
      end

      def curie
        m = name.match(/([^:]+):/)
        return m[1] if m

        statement.parameters(false).each do |param|
          next unless param&.respond_to? :source

          str = String(param.source)
          m = str.match(/curie:\s:?(\w+)/)
          return m[1] if m
        end

        nil
      end
    end
  end
end
