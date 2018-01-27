module Shaf
  module Generator
    class Model < Base

      identifier :model
      usage 'generate model MODEL_NAME'

      def call
        if model_name.empty?
          raise "Please provide a model name when using the model generator!"
        end

        puts "generating model #{model_name}.."
        create_model
        create_migration
      end

      def model_name
        args.first || ""
      end

      def table_name
        Utils::pluralize model_name
      end

      def template
        'app/model.rb'
      end

      def target
        "app/models/#{model_name}.rb"
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
          class_name: model_name.capitalize,
          form_fields: form_fields
        }
      end

      def create_migration
        migration_args = %W(create table #{table_name}) + args[1..-1]
        Migration::Generator.new(*migration_args).call
      end
    end
  end
end
