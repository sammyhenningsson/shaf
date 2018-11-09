require 'shaf/formable/form'

module Shaf
  module Formable
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
        @form ||= Formable::Form.new(method: @default_method)
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

      def create(&block)
        return unless @create
        call_nested_block(block)
      end

      def edit(&block)
        return unless @edit
        call_nested_block(block)
      end

      def call_nested_block(block)
        old, @block = @block, block
        call
      ensure
        @block = old
      end
    end
  end
end
