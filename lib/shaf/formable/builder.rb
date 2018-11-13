require 'shaf/formable/form'

module Shaf
  module Formable
    class Builder
      DELEGATES = %i[title name action method type fields].freeze

      attr_reader :forms

      def initialize(&block)
        @forms = []
        @instance_accessors = []

        exec_with_form(block)
      end

      def instance_accessor_for?(form)
        @instance_accessors.include? form
      end

      private

      attr_reader :form

      def exec_with_form(block, action: nil)
        current, @form = form, new_form
        form.action = action if action
        instance_exec(&block)
      ensure
        @form = current
      end

      def new_form
        (form&.dup || Formable::Form.new).tap { |f| @forms << f }
      end

      def instance_accessor
        @instance_accessors << form
      end

      DELEGATES.each do |name|
        define_method(name) do |arg|
          form.send("#{name}=".to_sym, arg)
        end
      end

      def field(name, opts = {})
        form.add_field(name, opts)
      end

      def method_missing(method, *args, &block)
        return super unless args.empty? && block
        exec_with_form(block, action: method)
      end

      def respond_to_missing?(*)
        true
      end
    end
  end
end
