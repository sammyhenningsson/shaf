# frozen_string_literal: true

require 'shaf/api_doc/link_relations'

module Shaf
  module Yard
    class LinkObject < ::YARD::CodeObjects::Base
      attr_accessor :rel, :curie

      def curie?
        !!curie
      end

      def documentation
        profile_doc || iana_doc
      end

      def profile_doc
        return unless namespace&.respond_to? :profile

        profile = namespace.profile
        return unless profile

        relation = profile.relations.find { |rel| rel.name.to_sym == name.to_sym }
        relation&.doc
      end

      def iana_doc
        ApiDoc::LinkRelations.load_iana
        ApiDoc::LinkRelations[name.to_sym]&.description
      end
    end
  end
end
