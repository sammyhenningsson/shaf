# frozen_string_literal: true

module Shaf
  module ALPS
    class AttributeSerializer
      attr_reader :attribute

      def self.call(arg)
        new(arg).to_hash
      end

      def initialize(attribute)
        @attribute = attribute
      end

      def to_hash
        {
          id: attribute.id,
          type: 'semantic',
          doc: {
            value: attribute.doc
          },
        }.merge(optional_properties)
      end

      private

      def optional_properties
        descriptors = serialized_descriptors
        hash = {}
        hash[:name] = attribute.name.to_s if attribute.name
        hash[:descriptor] = descriptors unless descriptors.empty?
        hash
      end

      def serialized_descriptors
        descriptors = attribute.attributes.map { |attr| self.class.call(attr) }
        descriptors += attribute.relations.map { |rel| RelationSerializer.call(rel) }
      end
    end
  end
end
