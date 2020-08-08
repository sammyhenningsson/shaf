module Shaf
  module Generator
    class Profile < Base
      identifier :profile
      usage 'generate profile MODEL_NAME'

      def call
        create_profile
      end

      def profile_name
        n = args.first || ""
        return n unless n.empty?
        raise Command::ArgumentError,
          "Please provide a profile name when using the profile generator!"
      end

      def model_class_name
        Utils::model_name(profile_name)
      end

      def template
        'api/profile.rb'
      end

      def target
        "api/profiles/#{profile_name}.rb"
      end

      def create_profile
        content = render(template, opts)
        write_output(target, content)
      end

      def attributes
        args[1..-1].map { |attr| "attribute :#{attr}" }
      end

      def opts
        {
          profile_name: profile_name,
          profile_class_name: "#{model_class_name}",
          attributes: attributes,
        }
      end
    end
  end
end
