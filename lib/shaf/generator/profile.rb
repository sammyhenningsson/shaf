module Shaf
  module Generator
    class Profile < Base
      identifier :profile
      usage 'generate profile NAME [attribute:type] [..]'

      def call
        create_profile
      end

      def template
        'api/profile.rb'
      end

      def target_dir
        'api/profiles'
      end

      def target_name
        "#{name}.rb"
      end

      def attributes
        args[1..-1].map do |attr|
          name, type = attr.split(':')
          type ||= 'String'
          [name, type.capitalize]
        end
      end

      def create_profile
        content = render(template, opts)
        content = wrap_in_module(content, module_name, search: 'class \w')
        write_output(target, content)
      end

      def opts
        {
          profile_name: name,
          profile_class_name: "#{model_class_name}",
          attributes: attributes,
        }
      end
    end
  end
end
