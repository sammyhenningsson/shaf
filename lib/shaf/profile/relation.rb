# frozen_string_literal: true

require 'shaf/profile/unique_id'

module Shaf
  class Profile
    class Relation
      include UniqueId

      attr_reader :name, :doc, :http_methods, :payload_type, :content_type, :parent

      def initialize(name, doc:, http_methods: nil, payload_type: nil, content_type: nil, **opts)
        @name = name.to_sym
        @doc = doc.freeze
        http_methods = Array(http_methods).tap { |a| a << 'GET' if a.empty? }
        @http_methods = http_methods.map { |m| m.to_s.upcase }.freeze
        @payload_type = payload_type.freeze
        @content_type = content_type.freeze
        @parent = opts[:parent]
      end

      def attributes
        @attributes ||= []
      end
    end
  end
end
