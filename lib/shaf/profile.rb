# frozen_string_literal: true

require 'shaf/profile/evaluator'
require 'shaf/extensions/resource_uris'

module Shaf
  class Profile
    module NormalizeName
      private def normalize(name)
        name.to_s.downcase.tr('-', '_')
      end
    end

    extend NormalizeName
    include NormalizeName
    include Shaf::UriHelper

    class << self
      def inherited(child)
        Profiles.register child
      end

      def name(str = nil)
        @name = str if str
        @name if defined? @name
      end

      def doc(str = nil)
        @doc = str if str
        @doc if defined? @doc
      end

      def urn(value = nil)
        @urn = value if value
        @urn if defined? @urn
      end

      def example(str)
        examples << str
      end

      def match?(str)
        normalize(name) == normalize(str)
      end

      def attributes
        @attributes ||= []
      end

      def relations
        @relations ||= []
      end

      def examples
        @examples ||= []
      end

      def attribute(*args, **kwargs, &block)
        evaluator.attribute(*args, **kwargs, &block)
      end

      def relation(*args, **kwargs, &block)
        evaluator.rel(*args, **kwargs, &block)
      end
      alias rel relation

      def descriptor(id)
        find_attribute(id) || find_relation(id)
      end

      def find_attribute(id)
        attributes.find { |attr| attr.id.to_sym == id.to_sym }
      end

      def find_relation(id)
        relations.find { |rel| rel.id.to_sym == id.to_sym }
      end

      def use(*descriptors, from:, doc: nil)
        descriptors.each do |id|
          desc = from.descriptor(id)
          href = profile_path(from.name, fragment_id: id)

          case desc
          when Relation
            kwargs = {
              doc: doc || desc&.doc,
              href: href,
              http_methods: desc.http_methods,
              payload_type: desc.payload_type,
              content_type: desc.content_type,
            }
            relation(id, **kwargs)
          when Attribute
            attribute(id, href: href, doc: doc)
          when NilClass
            raise "#{from.name} does not have a descriptor with id #{id}"
          else
            raise Errors::ServerError, "Unsupported descriptor: #{desc}"
          end
        end
      end

      private

      def evaluator
        Evaluator.new(parent: self)
      end
    end

    def name
      normalize(self.class.name)
    end
  end
end
