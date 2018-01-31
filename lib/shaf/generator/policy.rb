module Shaf
  module Generator
    class Policy < Base
      identifier :policy
      usage 'generate policy MODEL_NAME [attribute] [..]'

      def call
        if policy_name.empty?
          raise "Please provide a policy name when using the policy generator!"
        end
        create_policy
      end

      def policy_name
        args.first || ""
      end

      def template
        'app/policy.rb'
      end

      def target
        "app/policies/#{policy_name}.rb"
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
          policy_class_name: "#{policy_name.capitalize}Policy",
          attributes: attributes,
        }
      end
    end
  end
end
