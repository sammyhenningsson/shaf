module Shaf
  module Generator
    class Model < Base

      identifier :model
      usage 'generate model MODEL_NAME [attribute:type] [..]'

      def call
        create_model
        create_migration
        create_serializer
      end

      def model_name
        n = args.first || ""
        return n unless n.empty?
        raise Command::ArgumentError,
          "Please provide a model name when using the model generator!"
      end

      def model_class_name
        Utils::model_name(model_name)
      end

      def table_name
        Utils::pluralize model_name
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

      def form_fields
        args[1..-1].map do |f|
          (name, type, label) = f.split(':')
          label_str = label ? %(, label: "#{label}") : ''
          format 'field :%s, type: "%s"%s' % [name, rewrite(type), label_str]
        end
      end

      def rewrite(type)
        case type
        when /foreign_key/
          'integer'
        when NilClass
          'string'
        else
          type
        end
      end

      def opts
        {
          model_name: model_name,
          class_name: model_class_name,
          form_fields: form_fields
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
    end
  end
end
