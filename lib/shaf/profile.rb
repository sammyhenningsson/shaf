# frozen_string_literal: true

require 'shaf/profile/evaluator'
require 'shaf/extensions/resource_uris'

module Shaf
  class Profile
    include Shaf::UriHelper

    class << self
      def inherited(child)
        Profiles.register child
      end

      def name(str = nil)
        @name = str if str
        @name if defined? @name # prevent uninitialized warning
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

      def attribute(*args, **kwargs, &block)
        evaluator.attribute(*args, **kwargs, &block)
      end

      def relation(*args, **kwargs, &block)
        evaluator.rel(*args, **kwargs, &block)
      end
      alias rel relation

      def descriptor(id)
        attribute = attributes.find { |attr| attr.id.to_sym == id.to_sym }
        return attribute if attribute

        relations.find { |rel| rel.id.to_sym == id.to_sym }
      end

      def use(*descriptors, from:)
        descriptors.each do |id|
          desc = from.descriptor(id)

          case desc
          when Relation
            relation id,
              http_methods: desc.http_methods,
              href: profile_path(from.name, fragment_id: id)
          when Attribute
            attribute id,
              href: profile_path(from.name, fragment_id: id)
          when NilClass
            raise "#{from.name} does not have a descriptor with id #{id}"
          else
            raise "Unsupported descriptor: #{desc}"
          end
        end
      end

      private

      def evaluator
        Evaluator.new(parent: self)
      end

      def normalize(name)
        name.to_s.downcase.tr('-', '_')
      end
    end

    def name
      normalize(self.class.name)
    end

    def normalize(str)
      self.class.normalize(str)
    end
  end
end
