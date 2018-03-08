require 'minitest/assertions'

module Shaf
  module Spec
    module PayloadUtils

      class Embedded
        include HttpMethodUtils
        include PayloadUtils
        include Minitest::Assertions

        # This is needed by Minitest::Assertions
        # And we need that module to have all assert_*/refute_* methods
        # available in this class
        attr_accessor :assertions

        def initialize(payload, context, block)
          @payload = payload
          @context = context
          @block = block
          @assertions = 0
        end

        def call
          instance_exec(&@block)
        end

        def method_missing(method, *args, &block)
          if @context&.respond_to? method
            define_singleton_method(method) { |*a, &b| @context.public_send method, *a, &b }
            return public_send(method, *args, &block)
          end
          super
        end

        def respond_to_missing?(method, include_private = false)
          return true if @context&.respond_to? method
          super
        end

      end

      def set_payload(payload)
        @payload = payload
        @payload = JSON.parse(payload, symbolize_names: true) if payload.is_a?(String)
      end

      def last_payload
        refute @payload.nil?, "No previous response body"
        @payload
      end

      def attributes
        last_payload.reject { |key,_| [:_links, :_embedded].include? key }
      end

      def links
        last_payload[:_links] || []
      end

      def link_rels
        links.keys
      end

      def embedded_resources
        last_payload[:_embedded]&.keys || []
      end

      def embedded(name = nil)
        assert_has_embedded name
        keys = [:_embedded, name&.to_sym].compact
        return last_payload.dig(*keys) unless block_given?
        Embedded.new(last_payload.dig(*keys), self, Proc.new).call
      end

        end
      end

      def fill_form(fields)
        fields.map do |field|
          value = case field[:type]
                  when 'integer'
                    field[:name].size
                  when 'string'
                    "value for #{field[:name]}"
                  else
                    "type not supported"
                  end
          [field[:name], value]
        end.to_h
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
        assert last_payload[attr.to_sym],
          "Response does not contain attribute '#{attr}': #{last_payload}"
      end

      def refute_has_attribute(attr)
        refute last_payload[attr.to_sym],
          "Response contains disallowed attribute '#{attr}': #{last_payload}"
      end

      def assert_has_attributes(*attrs)
        attrs.each { |attr| assert_has_attribute(attr) }
      end

      def refute_has_attributes(*attrs)
        attrs.each { |attr| refute_has_attribute(attr) }
      end

      def assert_attribute(attr, expected)
        assert_has_attribute(attr)
        assert_equal expected, last_payload[attr.to_sym]
      end

      def assert_has_link(rel)
        assert last_payload.key?(:_links), "Response does not have any links: #{last_payload}"
        assert last_payload[:_links][rel.to_sym],
          "Response does not contain link with rel '#{rel}': #{last_payload}"
        assert last_payload[:_links][rel.to_sym][:href],
          "link with rel '#{rel}' in ressponse does not have a href: #{last_payload}"
      end

      def refute_has_link(rel)
        refute last_payload.dig(:_links, rel.to_sym),
          "Response contains disallowed link with rel '#{rel}': #{last_payload}"
      end

      def assert_has_links(*rels)
        rels.each { |rel| assert_has_link(rel) }
      end

      def refute_has_links(*rels)
        rels.each { |rel| refute_has_link(rel) }
      end

      def assert_link(rel, expected)
        assert_has_link(rel)
        assert_equal expected, last_payload.dig(:_links, rel.to_sym, :href)
      end

      def assert_has_embedded(*names)
        names.each do |name|
          assert last_payload.key?(:_embedded),
            "Response does not have any embedded resources: #{last_payload}"
          assert last_payload[:_embedded][name.to_sym],
            "Response does not contain embedded resource with name '#{name}': #{last_payload}"
        end
      end

      def refute_has_embedded(*names)
        names.each do |name|
          refute last_payload.dig(:_embedded, name.to_sym),
            "Response contains disallowed embedded resource with name '#{name}': #{last_payload}"
        end
      end
    end
  end
end
