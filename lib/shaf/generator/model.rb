module Shaf
  module Generator
    class Model < Base

      identifier :model
      usage 'generate model MODEL_NAME [attribute:type] [..]'

      def self.options(parser, options)
        parser.on("--skip-model", "don't generate model or migration") do |s|
          options[:skip_model] = s
        end

        parser.on("--skip-migration", "don't generate a migration") do |s|
          options[:skip_migration] = s
        end
      end

      def call
        create_model unless skip_model?
        create_migration unless skip_migration?
        create_serializer
        create_forms
      end

      private

      def skip_model?
        options[:skip_model]
      end

      def skip_migration?
        options[:skip_migration] || skip_model?
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
