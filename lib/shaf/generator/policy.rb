module Shaf
  module Generator
    class Policy < Base
      identifier :policy
      usage 'generate policy MODEL_NAME [attribute] [..]'

      def call
        create_policy
      end

      def template
        'api/policy.rb'
      end

      def target_dir
        'api/policies'
      end

      def target_name
        "#{name}_policy.rb"
      end

      def create_policy
        content = render(template, opts)
        content = wrap_in_module(content, module_name)
        write_output(target, content)
      end

      def attributes
        args[1..-1].map { |attr| "attribute :#{attr}" }
      end

      def opts
        {
          policy_class_name: "#{model_class_name}Policy",
          name: name,
          attributes: attributes,
        }
      end
    end
  end
end
