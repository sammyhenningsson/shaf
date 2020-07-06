# frozen_string_literal: true

module Shaf
  module Yard
    class AttributeObject < ::YARD::CodeObjects::Base
      attr_accessor :name

      def documentation
        description || profile_doc || 'Not documented'
      end

      def profile_doc
        return unless namespace&.respond_to? :profile

        profile = namespace.profile
        return unless profile

        attribute = profile.attributes.find { |attr| attr.name.to_sym == name.to_sym }
        attribute&.doc
      end

      def value_type
        tags(:type).first&.types&.join(', ')
      end

      def description
        tags(:description).first&.text
      end
    end
  end
end
