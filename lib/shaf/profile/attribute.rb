# frozen_string_literal: true

require 'shaf/profile/unique_id'

module Shaf
  class Profile
    class Attribute
      include UniqueId

      attr_reader :name, :doc, :href, :type, :parent

      def initialize(name, **opts)
        @name = name.to_sym
        @doc = opts[:doc].freeze
        @href = opts[:href].freeze
        @type = opts[:type]&.to_sym
        @parent = opts[:parent]
      end

      def attributes
        @attributes ||= []
      end

      def relations
        @relations ||= []
      end
    end
  end
end
