# frozen_string_literal: true

require 'shaf/api_doc/link_relations'

module Shaf
  module Yard
    class LinkObject < ::YARD::CodeObjects::Base
      SOURCE_IANA = 'iana'

      attr_accessor :rel, :curie

      def curie?
        !!curie
      end

      def documentation
        profile_doc || iana_doc || 'Undocumented'
      end

      def profile
        return unless namespace.respond_to? :profile
        @profile ||= namespace.profile
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
        ApiDoc::LinkRelations.load_iana
        ApiDoc::LinkRelations[name.to_sym]&.description
      end

      def source
        if descriptor
          profile.name
        elsif iana_doc
          SOURCE_IANA
        end
      end
    end
  end
end
