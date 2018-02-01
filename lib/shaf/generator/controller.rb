module Shaf
  module Generator
    class Controller < Base

      identifier :controller
      usage 'generate controller RESOURCE_NAME'

      def call
        if name.empty?
          raise Command::ArgumentError,
            "Please provide a controller name when using the controller generator!"
        end

        create_controller
      end

      def name
        args.first || ""
      end
      
      def plural_name
        Utils::pluralize(name)
      end

      def template
        'app/controller.rb'
      end

      def target
        "app/controllers/#{name}.rb"
      end

      def create_controller
        content = render(template, opts)
        write_output(target, content)
      end

      def opts
        {
          name: name,
          plural_name: plural_name,
          model_class_name: name.capitalize,
          controller_class_name: "#{plural_name.capitalize}Controller"
        }
      end
    end
  end
end
