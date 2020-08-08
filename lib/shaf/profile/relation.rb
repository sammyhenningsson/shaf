# frozen_string_literal: true

require 'shaf/profile/unique_id'

module Shaf
  class Profile
    class Relation
      include UniqueId

      attr_reader :name, :doc, :href, :http_methods, :payload_type, :content_type, :parent

      def initialize(name, **opts)
        @name = name.to_sym
        @doc = opts[:doc].freeze
        @href = opts[:href].freeze
        http_methods = Array(opts[:http_method]) + Array(opts[:http_methods])
        http_methods  << 'GET' if http_methods.empty?
        @http_methods = http_methods.map { |m| m.to_s.upcase }.uniq.freeze
        @payload_type = opts[:payload_type].freeze
        @content_type = opts[:content_type].freeze
        @parent = opts[:parent]
      end

      def attributes
        @attributes ||= []
      end
    end
  end
end
