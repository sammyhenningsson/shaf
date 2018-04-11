module Shaf
  module Generator
    class Model < Base

      identifier :model
      usage 'generate model MODEL_NAME [attribute:type] [..]'

      def call(options = {})
        create_model
        create_migration
        create_serializer(options)
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
          type ||= "string"
          label_str = label ? %Q(, label: "#{label}") : ""
          format 'field :%s, type: "%s"%s' % [name, type, label_str]
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

      def create_serializer(options)
        serializer_args = %W(serializer #{model_name})
        serializer_args += args[1..-1].map { |arg| arg.split(':').first }
        Generator::Factory.create(*serializer_args).call(options)
      end
    end
  end
end
