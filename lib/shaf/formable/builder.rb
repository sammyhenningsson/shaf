require 'forwardable'
require 'shaf/formable/form'
require 'shaf/immutable_attr'

module Shaf
  module Formable
    class Builder
      DELEGATES = %i[title name action method type submit fields].freeze

      class FormWrapper
        extend Forwardable
        extend Shaf::ImmutableAttr

        attr_accessor :instance_accessor
        immutable_reader :form

        WRITER_DELEGATES = DELEGATES.map { |method| :"#{method}=" }
        def_delegators :@form, :add_field, *WRITER_DELEGATES

        def initialize(form, method_name: nil, instance_accessor: nil)
          @form = form&.dup || Formable::Form.new
          @method_name = method_name
          @form.action = action_from(method_name) unless @form.action
          @instance_accessor = instance_accessor
        end

        def action_from(method_name)
          return unless method_name

          (method_name.to_s.delete_suffix('_form')).to_sym
        end

        def method_name
          name = @method_name || form.action

          if name.nil?
            nil
          elsif name.to_s.end_with? '_form'
            name.to_sym
          else
            :"#{name}_form"
          end
        end

        def instance_accessor?
          [:empty, :prefill].include? instance_accessor
        end

        def prefill?
          instance_accessor == :prefill
        end
      end

      attr_reader :forms

      def initialize(&block)
        @forms = []
        @instance_accessors = {}

        exec_with_form(block)
      end

      private

      attr_reader :current

      def exec_with_form(block, method_name: nil)
        prev, @current = current, new_form(method_name)
        instance_exec(&block)
      ensure
        @current = prev
      end

      def new_form(method_name)
        FormWrapper.new(current&.form, method_name: method_name).tap { |f| @forms <<  f }
      end

      def instance_accessor(prefill: true)
        current.instance_accessor = prefill ? :prefill : :empty
      end

      DELEGATES.each do |name|
        define_method(name) do |arg|
          current.send(:"#{name}=", arg)
        end
      end

      def field(name, opts = {})
        current.add_field(name, opts)
      end

      def method_missing(method, *args, &block)
        return super unless args.empty? && block
        exec_with_form(block, method_name: method)
      end

      def respond_to_missing?(method, _include_private = false)
        method.to_s.end_with?('_form') ? true : super
      end
    end
  end
end
