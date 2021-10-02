require 'shaf/formable/field'
require 'shaf/immutable_attr'

module Shaf
  module Formable
    class Form
      extend Shaf::ImmutableAttr

      class FormHasNoResourceError < Shaf::Error; end

      DEFAULT_TYPE = 'application/json'.freeze
      DEFAULT_SUBMIT = 'save'.freeze

      attr_accessor :resource
      attr_writer :name, :action
      immutable_accessor :title, :href, :type, :submit, :self_link
      immutable_reader :fields

      def initialize(params = {})
        @title = params[:title]
        @action = params[:action]
        @name = params[:name]
        @method = params[:method]
        @type = params[:type] || DEFAULT_TYPE
        @submit = params[:submit] || DEFAULT_SUBMIT
        @fields = (params[:fields] || {}).map do |name, args|
          Field.new(name, args)
        end
      end

      def name
        (@name || name_from(action))&.to_sym
      end

      def method=(http_method)
        @method = http_method.to_s.upcase
      end

      def method
        _method = @method || http_method_from(action)
        _method.to_s.upcase if _method
      end

      def fields=(fields)
        @fields = fields.map { |name, args| Field.new(name, args) }
      end

      def action
        @action&.to_sym
      end

      def add_field(name, opts)
        @fields << Field.new(name, opts)
      end

      def dup
        super.tap do |obj|
          obj.instance_variable_set(:@fields, @fields.map(&:dup))
        end
      end

      def clone
        dup.tap { |obj| obj.freeze if frozen? }
      end

      def fill!(from: nil)
        resrc = from || resource
        raise FormHasNoResourceError, <<~MSG unless resrc
          Trying to fill form with values from resource, but form '#{name}' has no resource!
        MSG

        fields.each do |field|
          accessor_name = field.accessor_name
          next unless resrc.respond_to? accessor_name
          field.value = resrc.send(accessor_name)
        end
      end

      def [](name)
        fields.find { |field| field.name == name }
      end

      def to_html
        form_element do
          [
            hidden_method_element,
            fields.map(&:to_html).join("\n"),
            submit_element
          ].compact.join("\n")
        end
      end

      private

      def name_from(action)
        :"#{action.to_s.tr('_', '-')}-form" if action
      end

      def http_method_from(action)
        return unless action
        action&.to_sym == :edit ? 'PUT' : 'POST'
      end

      def form_element
        [
          %Q(<form class="form" method=#{method == 'GET' ? 'GET' : 'POST'}#{href ? %Q( action="#{href.to_s}") : ''}>),
          block_given? ? yield : nil,
          '</form>'
        ].compact.join("\n")
      end

      def hidden_method_element
        return if %w[GET POST].include? method
        %Q(<input type="hidden" name="_method" value="#{method}">)
      end

      def submit_element
        %Q(<div class="form--input-group"><input type="submit" class="button" value="#{submit}"</div>)
      end
    end
  end
end
