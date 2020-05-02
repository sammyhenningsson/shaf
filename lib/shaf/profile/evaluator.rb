# frozen_string_literal: true

require 'shaf/profile/attribute'
require 'shaf/profile/relation'

module Shaf
  class Profile
    class Evaluator
      attr_reader :parent, :allowed

      def initialize(parent:, allowed: nil)
        @parent = parent
        @allowed = allowed && Array(allowed).map(&:to_sym)
      end

      def attribute(name, doc:, type: :string, &block)
        return unless allow? :attribute

        attr = Attribute.new(name, doc: doc, type: type, parent: parent)
        self.class.new(parent: attr, allowed: allowed).instance_exec(&block) if block
        parent.attributes << attr
      end

      def rel(name, **kwargs, &block)
        return unless allow? :rel

        rel = Relation.new(name, parent: parent, **kwargs)
        self.class.new(parent: rel, allowed: [:attribute]).instance_exec(&block) if block
        parent.relations << rel
      end

      private

      def allow?(name)
        return true unless allowed
        return true if allowed.include? name

        $logger&.warn "#{name} is not allowed to be nested inside #{parent.class} " \
          "(or parent object containing #{parent.class})"

        false
      end
    end
  end
end
