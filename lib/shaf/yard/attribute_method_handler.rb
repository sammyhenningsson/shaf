# frozen_string_literal: true

require 'shaf/yard/base_method_handler'

module Shaf
  module Yard
    # Handles call to Shaf::Serializer::attribute
    class AttributeMethodHandler < BaseMethodHandler
      handles method_call(:attribute)

      def object
        AttributeObject.new(serializer_namespace, name).tap do |attr|
          attr.dynamic = true
          attr.name = name
        end
      end
    end
  end
end
