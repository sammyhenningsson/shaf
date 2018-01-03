require 'minitest/assertions'

module TestUtils
  module Payload

    class Embedded
      include Payload
      include Minitest::Assertions

      # This is needed by Minitest::Assertions
      # And we need that module to have all assert_*/refute_* methods
      # available in this class
      attr_accessor :assertions

      def initialize(payload, block)
        @payload = payload
        @block = block
        @assertions = 0
      end

      def call
        instance_exec &@block
      end
    end

    def payload(payload = nil)
      if payload.nil?
        refute @payload.nil?, "No previous response body"
      else
        @payload = payload
        @payload = JSON.parse(payload, symbolize_names: true) if payload.is_a?(String)
      end
      @payload
    end

    def attribute
      payload
    end

    def links
      payload[:_links]
    end

    def embedded(name = nil)
      keys = [:_embedded, name&.to_sym].compact
      return payload.dig(*keys) unless block_given?
      Embedded.new(payload.dig(*keys), Proc.new).call
    end

    def follow_rel(rel, method: nil)
      assert_has_link(rel)
      link = links[rel.to_sym]
      if method && respond_to?(method)
        public_send(method, link[:href])
      else
        get link[:href]
      end
    end

    def assert_status(code)
      assert_equal code, status,
        "Response status was expected to be #{code}."
    end

    def assert_header(key, value)
      assert_equal value, headers[key],
        "Response was expected have header #{key} = #{value}."
    end

    def assert_has_attribute(attr)
      assert payload[attr.to_sym],
        "Response does not contain attribute '#{attr}': #{payload}"
    end

    def refute_has_attribute(attr)
      refute payload[attr.to_sym],
        "Response contains disallowed attribute '#{attr}': #{payload}"
    end

    def assert_has_attributes(*attrs)
      attrs.each { |attr| assert_has_attribute(attr) }
    end

    def refute_has_attributes(*attrs)
      attrs.each { |attr| refute_has_attribute(attr) }
    end

    def assert_attribute(attr, expected)
      assert_has_attribute(attr)
      assert_equal expected, payload[attr.to_sym]
    end

    def assert_has_link(rel)
      assert payload.key?(:_links), "Response does not have any links: #{payload}"
      assert payload[:_links][rel.to_sym],
        "Response does not contain link with rel '#{rel}': #{payload}"
      assert payload[:_links][rel.to_sym][:href],
        "link with rel '#{rel}' in ressponse does not have a href: #{payload}"
    end

    def refute_has_link(rel)
      refute payload.dig(:_links, rel.to_sym),
        "Response contains disallowed link with rel '#{rel}': #{payload}"
    end

    def assert_has_links(*rels)
      rels.each { |rel| assert_has_link(rel) }
    end

    def refute_has_links(*rels)
      rels.each { |rel| refute_has_link(rel) }
    end

    def assert_link(rel, expected)
      assert_has_link(rel)
      assert_equal expected, payload.dig(:_links, rel.to_sym, :href)
    end

    def assert_has_embedded(*names)
      names.each do |name|
        assert payload.key?(:_embedded),
          "Response does not have any embedded resources: #{payload}"
        assert payload[:_embedded][name.to_sym],
          "Response does not contain embedded resource with name '#{name}': #{payload}"
      end
    end

    def refute_has_embedded(*names)
      names.each do |name|
        refute payload.dig(:_embedded, name.to_sym),
          "Response contains disallowed embedded resource with name '#{name}': #{payload}"
      end
    end
  end
end
