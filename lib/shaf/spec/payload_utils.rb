require 'minitest/assertions'

module Shaf
  module Spec
    module PayloadUtils
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
        assert_has_embedded name unless name.nil?
        keys = [:_embedded, name&.to_sym].compact
        return last_payload.dig(*keys) unless block_given?
        exec_embed_block(last_payload.dig(*keys), Proc.new)
      end

      def each_embedded(name, &block)
        assert_has_embedded name
        list = last_payload[:_embedded][name]

        assert_instance_of Array, list,
          "Embedded '#{name}' is not an instance of Array. Actual: #{list.class}"

        list.each_with_index do |resource, i|
          exec_embed_block(resource, block, i)
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

      private

      def exec_embed_block(payload, block, *args)
        prev_payload = last_payload
        set_payload(payload)
        instance_exec(*args, &block)
        set_payload(prev_payload)
      end
    end
  end
end
