# frozen_string_literal: true

module Shaf
  module Yard
    module NestedAttributes
      def nested_attributes_for(descriptor)
        return {} unless descriptor

        base_key = nested_key(descriptor)
        nested_attributes(descriptor)
          .yield_self { |nested| flatten(nested, base_key) }
      end

      def nested_attributes(descriptor)
        attrs = Array(descriptor&.attributes)
        attrs.each_with_object({}) do |attr, nested|
          nested[attr] = nested_attributes(attr)
        end.transform_values { |v| v.empty? ? nil : v }
      end

      def flatten(nested, base_key)
        return {} if !nested || nested.empty?

        nested.each_with_object({}) do |(desc, nested), all|
          key = nested_key(base_key, desc)
          all[key] = desc
          next unless nested
          all.merge!(flatten(nested, key))
        end
      end

      def nested_key(base_key = nil, desc)
        [base_key, desc.name].compact.join('.')
      end
    end
  end
end
