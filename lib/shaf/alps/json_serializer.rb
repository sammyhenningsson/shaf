# frozen_string_literal: true

require 'shaf/alps/attribute_serializer'
require 'shaf/alps/relation_serializer'

module Shaf
  module ALPS
    class JsonSerializer
      ALPS_VERSION = '1.0'

      def self.call(profile)
        new(profile).to_hash
      end

      attr_reader :profile

      def initialize(profile)
        @profile = profile
      end

      def to_hash
        {
          alps: {
            version: ALPS_VERSION,
            # doc: profile.doc, # FIXME add toplevel profile documentation
            descriptor: descriptors,
          }
        }
      end

      private

      def descriptors
        attribute_descriptors + relation_descriptors
      end

      def attribute_descriptors
        profile.attributes.map do |desc|
          AttributeSerializer.call(desc)
        end
      end

      def relation_descriptors
        profile.relations.map do |desc|
          RelationSerializer.call(desc)
        end
      end
    end
  end
end
