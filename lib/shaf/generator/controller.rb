module Shaf
  module Generator
    class Controller < Base

      identifier :controller
      usage 'generate controller RESOURCE_NAME [attribute:type] [..]'

      def call(options = {})
        create_controller
        create_integration_spec if options[:specs]
        add_link_to_root
      end

      def params
        args[1..-1].map { |param| param.split(':')}
      end

      def name
        n = args.first || ""
        return n unless n.empty?
        raise Command::ArgumentError,
          "Please provide a controller name when using the controller generator!"
      end

      def model_class_name
        Utils::model_name(name)
      end

      def plural_name
        Utils::pluralize(name)
      end

      def pluralized_model_name
        Utils::pluralize(model_class_name)
      end

      def template
        'api/controller.rb'
      end

      def spec_template
        'spec/integration_spec.rb'
      end

      def target
        "api/controllers/#{plural_name}_controller.rb"
      end

      def spec_target
        "spec/integration/#{plural_name}_controller_spec.rb"
      end

      def create_controller
        content = render(template, opts)
        write_output(target, content)
      end

      def create_integration_spec
        content = render(spec_template, opts)
        write_output(spec_target, content)
      end

      def opts
        {
          name: name,
          plural_name: plural_name,
          serializer_class_name: "#{model_class_name}Serializer",
          model_class_name: model_class_name,
          controller_class_name: "#{pluralized_model_name}Controller",
          policy_class_name: "#{model_class_name}Policy",
          policy_file: "policies/#{name}_policy",
          params: params
        }
      end

      def add_link_to_root
        file = "api/serializers/root_serializer.rb"
        unless File.exist? file
          puts "Warning: file '#{file}' does not exist. "\
            "Skip adding link to the #{plural_name} collection"
        end
        added = false
        content = []
        File.readlines(file).reverse.each do |line|
          if match = !added && line.match(/^(\s*)link /)
            content.unshift link_content("#{match[1]}")
            added = true
          end
          content.unshift(line)
        end
        File.open(file, 'w') { |f| f.puts content }
        puts "Modified:   #{file}"
      end

      def link_content(indentation = "")
        <<~EOS.split("\n").map { |line| "#{indentation}#{line}" }

          # Auto generated doc:  
          # Link to the collection of #{plural_name}.  
          # Method: GET  
          # Example:
          # ```
          # curl -H "Accept: application/hal+json" \\
          #      -H "Authorization: abcdef" \\
          #      /#{plural_name}
          #```
          link :#{plural_name}, #{plural_name}_uri
        EOS
      end
    end
  end
end
