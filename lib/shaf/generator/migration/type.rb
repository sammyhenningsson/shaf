module Shaf
  module Generator
    module Migration
      class Type
        attr_reader :name, :create_template, :alter_template, :validator

        def initialize(str, create_template:, alter_template:, validator: nil)
          @name = str.downcase.to_sym
          @create_template = create_template.freeze
          @alter_template = alter_template.freeze
          @validator = validator.freeze
          freeze
        end

        def build(str, create: false, alter: false)
          args = parse_args(str)
          validate!(*args)

          if create && !alter
            build_create_string(*args)
          elsif alter && !create
            build_alter_string(*args)
          else
            [
              build_create_string(*args),
              build_alter_string(*args)
            ]
          end
        end

        def parse_args(str)
          name, col_type  = str.to_s.downcase.split(':')
          _, *args = col_type&.split(',')
          args.unshift name
        end

        def build_create_string(*args)
          format create_template, *args
        rescue ArgumentError
          raise Command::ArgumentError,
            "Wrong number of arguments for type #{name} with string " \
            "template '#{create_template}. Given: #{args}"
        end

        def build_alter_string(*args)
          format alter_template, *args
        rescue ArgumentError
          raise Command::ArgumentError,
            "Wrong number of arguments for type #{name} with string " \
            "template '#{alter_template}. Given: #{args}"
        end

        def validate!(*args)
          errors = Array(validator&.call(name, *args))
          return if errors.empty?

          raise "Failed to process '#{name}': #{errors&.join(', ')}"
        end

        def ==(other)
          name == other.name
        end
      end
    end
  end
end
