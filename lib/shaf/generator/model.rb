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

      def model_name
        n = args.first || ''
        return n unless n.empty?
        raise Command::ArgumentError,
          'Please provide a model name when using the model generator!'
      end

      def model_class_name
        Utils.model_name(model_name)
      end

      def table_name
        Utils.pluralize model_name
      end

      def template
        'api/model.rb'
      end

      def target
        "api/models/#{model_name}.rb"
      end

      def create_model
        content = render(template, opts)
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
        serializer_args = %W(serializer #{model_name})
        serializer_args += args[1..-1].map { |arg| arg.split(':').first }
        Generator::Factory.create(*serializer_args, **options).call
      end

      def create_forms
        form_args = %W(forms #{model_name}) + args[1..-1]
        Generator::Factory.create(*form_args, **options).call
      end
    end
  end
end
