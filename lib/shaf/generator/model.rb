module Shaf
  module Generator
    class Model < Base

      identifier :model
      usage 'generate model MODEL_NAME [attribute:type] [..]'

      def call
        create_model
        create_migration
        create_serializer
        create_forms
      end

      def table_name
        Utils.pluralize name_arg
      end

      def template
        'api/model.rb'
      end

      def target_dir
        'api/models'
      end

      def target_name
        "#{name}.rb"
      end

      def create_model
        content = render(template, opts)
        content = wrap_in_module(content, module_name)
        write_output(target, content)
      end

      def opts
        {
          class_name: model_class_name,
        }
      end

      def create_migration
        migration_args = %W(create table #{table_name}) + args[1..-1]
        Migration::Generator.new(*migration_args).call
      end

      def create_serializer
        serializer_args = %W(serializer #{name_arg}) + args[1..-1]
        Generator::Factory.create(*serializer_args, **options).call
      end

      def create_forms
        form_args = %W(forms #{name_arg}) + args[1..-1]
        Generator::Factory.create(*form_args, **options).call
      end
    end
  end
end
