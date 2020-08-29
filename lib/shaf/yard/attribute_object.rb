# frozen_string_literal: true

module Shaf
  module Yard
    class AttributeObject < ::YARD::CodeObjects::Base
      attr_accessor :name

      def documentation
        profile_doc || 'Not documented'
      end

      def profile
        return unless namespace.respond_to? :profile
        @profile ||= namespace.profile
      end

      def value_types
        Array(descriptor&.type).compact.map(&:to_s)
      end

      def profile_doc
        descriptor&.doc
      end

      def descriptor
        profile&.find_attribute(name)
      end
    end
  end
end
