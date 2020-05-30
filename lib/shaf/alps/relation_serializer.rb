# frozen_string_literal: true

module Shaf
  module ALPS
    class RelationSerializer
      SAFE_METHODS = ['GET', 'HEAD', 'OPTIONS']
      IDEMPOTENT_METHODS = ['PUT', 'PATCH', 'DELETE']
      UNSAFE_METHODS = ['POST']

      attr_reader :rel

      def self.call(arg)
        new(arg).to_hash
      end

      def initialize(rel)
        @rel = rel
      end

      def to_hash
        {
          id: rel.id,
          type: type,
          doc: {
            value: rel.doc
          },
        }.merge(optional_properties)
      end

      private

      def optional_properties
        descriptors = serialized_descriptors
        hash = {}
        hash[:name] = rel.name.to_s if rel.name
        hash[:rt] = rel.content_type if rel.content_type
        hash[:descriptor] = descriptors unless descriptors.empty?
        hash
      end

      def type
        methods = rel.http_methods
        if methods.all? { |m| SAFE_METHODS.include? m }
          'safe'
        elsif methods.all? { |m| (SAFE_METHODS + IDEMPOTENT_METHODS).include? m }
          'idempotent'
        else
          'unsafe'
        end
      end

      def serialized_descriptors
        rel.attributes.map { |attr| AttributeSerializer.call(attr) }
      end
    end
  end
end
