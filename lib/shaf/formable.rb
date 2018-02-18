module Shaf
  module Formable
    class Field
      attr_reader :name, :type, :value, :label

      def initialize(name, params = {})
        @name = name
        @type = params[:type]
        @label = params[:label]
        @has_value = params.key? :value
        @value = params[:value]
      end

      def has_value?
        @has_value
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
        return unless label
        %Q(<label for="#{name}" class="form--label">#{label.to_s}</label>)
      end

      def input_element
        _value = value ? %Q( value="#{value.to_s}") : ""
        %Q(<input type="#{type.to_s}" class="form--input" id="#{name.to_s}" name="#{name.to_s}"#{_value}>)
      end
    end

    class Form

      DEFAULT_TYPE = 'application/json'

      attr_accessor :resource, :name, :title, :href, :type, :self_link
      attr_reader :fields

      def initialize(params = {})
        @name = params[:name]
        @title = params[:title]
        @method = params[:method] || 'POST'
        @type = params[:type] || DEFAULT_TYPE
        @fields = (params[:fields] || {}).map { |name, args| Field.new(name, args) }
      end

      def method=(m)
        @method = m.to_s.upcase
      end

      def method
        @method.to_s.upcase
      end

      def fields=(fields)
        @fields = fields.map { |name, args| Field.new(name, args) }
      end

      def add_field(name, opts)
        @fields << Field.new(name, opts)
      end

      def to_html
        form_element do
          [
            hidden_method_element,
            fields.map { |f| f.to_html }.join("\n"),
            submit_element,
          ].compact.join("\n")
        end
      end

      private

      def form_element
        [
          %Q(<form class="form" method=#{method == 'GET' ? 'GET' : 'POST'}#{href ? %Q( action="#{href.to_s}") : ''}>),
          block_given? ? yield : nil,
          "</form>",
        ].compact.join("\n")
      end

      def hidden_method_element
        return if ['GET', 'POST'].include?(method)
        %Q(<input type="hidden" name="_method" value="#{method}">)
      end

      def submit_element
        %Q(<div class="form--input-group"><input type="submit" class="button" value="Submit"</div>)
      end
    end

    class Builder
      def self.call(block)
        [
          new(block, create: true).call,
          new(block, edit: true).call
        ]
      end

      attr_reader :block

      def initialize(block, create: false, edit: false)
        @block = block
        @create = create
        @edit = edit
        @form = nil
        @default_method = @create ? :post : :put
      end

      def call
        instance_exec(&block)
        @form
      end

      def form
        @form ||= Form.new(method: @default_method)
      end

      def name(name)
        form.name = name
      end

      def title(title)
        form.title = title
      end

      def method(method)
        form.method = method
      end

      def type(type)
        form.type = type
      end

      def fields(fields)
        form.fields = fields
      end

      def field(name, opts = {})
        form.add_field(name, opts)
      end

      def create(&b)
        return unless @create
        call_nested_block(b)
      end

      def edit(&b)
        return unless @edit
        call_nested_block(b)
      end

      def call_nested_block(b)
        old, @block = @block, b
        call
      ensure
        @block = old
      end
    end

    module ClassMethods
      attr_reader :create_form, :edit_form

      def form(&block)
        @create_form, @edit_form = Builder.(block)
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    def edit_form
      self.class.edit_form.tap do |form|
        form&.resource = self
      end
    end
  end
end
