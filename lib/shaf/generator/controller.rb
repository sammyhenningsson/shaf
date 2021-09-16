require 'file_transactions'

module Shaf
  module Generator
    class Controller < Base

      identifier :controller
      usage 'generate controller RESOURCE_NAME [attribute:type] [..]'

      def call
        create_controller
        create_integration_spec if options[:specs]
        add_link_to_root
      end

      private

      def pluralized_model_name
        Utils.pluralize(model_class_name)
      end

      def template
        'api/controller.rb'
      end

      def spec_template
        'spec/integration_spec.rb'
      end

      def target_dir
        'api/controllers'
      end

      def target_name
        "#{plural_name}_controller.rb"
      end

      def spec_target
        target(directory: 'spec/integration', name: "#{plural_name}_controller_spec.rb")
      end

      def policy_file
        File.join(['policies', namespace, "#{name}_policy"].compact)
      end

      def create_controller
        content = render(template, opts)
        content = wrap_in_module(content, module_name)
        write_output(target, content)
      end

      def create_integration_spec
        content = render(spec_template, opts)
        content = wrap_in_module(content, module_name, search: "describe #{model_class_name}")
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
          policy_file: policy_file,
          namespace: namespace,
          params: params
        }
      end

      def add_link_to_root
        file = 'api/serializers/root_serializer.rb'
        unless File.exist? file
          puts "Warning: file '#{file}' does not exist. "\
            "Skip adding link to the #{plural_name} collection"
        end
        added = false
        content = []
        FileTransactions::ChangeFileCommand.execute(file) do
          File.readlines(file).reverse_each do |line|
            if match = !added && line.match(/^(\s*)link /)
              content.unshift link_content(match[1].to_s)
              added = true
            end
            content.unshift(line)
          end
          File.open(file, 'w') { |f| f.puts content }
          puts "Modified:   #{file}"
        end
      end

      def link_content(indentation = '')
        "#{indentation}link :#{plural_name}, #{plural_name}_uri"
      end
    end
  end
end
