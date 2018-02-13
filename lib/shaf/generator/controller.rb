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
        create_integration_spec
        add_link_to_root
      end

      def name
        args.first || ""
      end

      def params
        args[1..-1]
      end
      
      def plural_name
        Utils::pluralize(name)
      end

      def template
        'api/controller.rb'
      end

      def spec_template
        'spec/integration_spec.rb'
      end

      def target
        "api/controllers/#{name}.rb"
      end

      def spec_target
        "spec/integration/#{name}_spec.rb"
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
          serializer_class_name: "Serializers::#{name.capitalize}",
          model_class_name: name.capitalize,
          controller_class_name: "#{plural_name.capitalize}Controller",
          policy_class_name: "#{name.capitalize}Policy",
          policy_file: "policies/#{name}",
          params: params
        }
      end

      def add_link_to_root
        file = "api/serializers/root.rb"
        unless File.exist? file
          puts "Warning: file '#{file}' does not exist. "\
            "Not adding any link to the #{plural_name} collection"
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
          # curl -H "Accept: application/json" \\
          #      -H "Authorization: abcdef" \\
          #      /#{plural_name}/5
          #```
          link :#{plural_name}, #{plural_name}_uri
        EOS
      end
    end
  end
end
