module Shaf
  module Generator
    class Policy < Base
      identifier :policy
      usage 'generate policy MODEL_NAME [attribute] [..]'

      def call
        create_policy
      end

      def policy_name
        n = args.first || ""
        return n unless n.empty?
        raise Command::ArgumentError,
          "Please provide a policy name when using the policy generator!"
      end

      def model_class_name
        Utils::model_name(policy_name)
      end

      def template
        'api/policy.rb'
      end

      def target
        "api/policies/#{policy_name}_policy.rb"
      end

      def create_policy
        content = render(template, opts)
        write_output(target, content)
      end

      def attributes
        args[1..-1].map { |attr| "attribute :#{attr}" }
      end

      def opts
        {
          policy_class_name: "#{model_class_name}Policy",
          name: policy_name,
          attributes: attributes,
        }
      end
    end
  end
end
