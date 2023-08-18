# frozen_string_literal: true

require 'shaf/link_relations'

module Shaf
  module Yard
    class LinkObject < ::YARD::CodeObjects::Base
      attr_accessor :rel, :curie

      def curie?
        !!curie
      end

      def documentation
        profile_doc || iana_doc || 'Undocumented'
      end

      def profile_object
        return unless profile
        return unless namespace.respond_to? :profile_objects

        namespace.profile_objects.find do |po|
          po.profile == profile
        end
      end

      def profile
        return @profile if defined? @profile
        return unless namespace.respond_to? :profile
        profile = namespace.profile
        @profile = profile&.find_relation(name) && profile
      end

      def descriptor
        profile&.find_relation(rel)
      end

      def profile_doc
        descriptor&.doc
      end

      def http_methods
        Array(descriptor&.http_methods)
      end

      def href
        descriptor&.href
      end

      def content_type
        descriptor&.content_type
      end

      def iana_doc
        LinkRelations.get(name)&.description
      end
    end
  end
end
