require 'shaf/immutable_attr'

module Shaf
  module Formable
    class Field
      extend Shaf::ImmutableAttr

      immutable_reader :name, :type, :value, :label, :required, :accessor_name

      HTML_TYPE_MAPPINGS = {
        string: 'text',
        boolean: 'checkbox'
      }.freeze

      def initialize(name, params = {})
        @name = name
        @type = params[:type]&.to_sym
        @label = params[:label]
        @has_value = params.key? :value
        @value = params[:value]
        @required = params[:required] || false
        @accessor_name = (params[:accessor_name] || name).to_sym
      end

      def has_value?
        @has_value
      end

      def value=(v)
        @value = v
        @has_value = true
      end

      def to_html
        [
          '<div class="form--input-group">',
          label_element,
          input_element,
          '</div>'
        ].compact.join("\n")
      end

      private

      def label_element
        str = (label || name || "").to_s
        %Q(<label for="#{name}" class="form--label">#{str}</label>)
      end

      def input_element
        _value = value ? %Q(value="#{value.to_s}") : nil
        _required = required ? "required" : nil
        attributes = [
          %Q(type="#{HTML_TYPE_MAPPINGS[type.to_s]}"),
          'class="form--input"',
          %Q(id="#{name.to_s}"),
          %Q(name="#{name.to_s}"),
        ]
        attributes << %Q(value="#{value.to_s}") if value
        attributes << "required" if required

        "<input #{attributes.join(" ")}>"
      end
    end
  end
end
