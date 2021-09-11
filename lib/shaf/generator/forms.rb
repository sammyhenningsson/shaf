# frozen_string_literal: true

module Shaf
  module Generator
    class Forms < Base
      identifier :forms
      usage 'generate forms MODEL_NAME [attribute:type[:label]] [..]'

      def call
        create_forms
      end

      def class_name
        "#{model_class_name}Forms"
      end

      def template
        'api/forms.rb'
      end

      def target_dir
        'api/forms'
      end

      def target_name
        "#{name}_forms.rb"
      end

      def create_forms
        content = render(template, opts)
        content = wrap_in_module(content, module_name)
        # FIXME: Append if file exists!
        write_output(target, content)
      end

      def opts
        {
          model_name: name,
          class_name: class_name,
          model_class_name: model_class_name,
          fields: fields
        }
      end

      def fields
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
    end
  end
end
