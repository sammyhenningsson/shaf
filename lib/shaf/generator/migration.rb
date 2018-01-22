require 'date'

module Shaf
  module Generator
    module Migration

      class Registry
        extend Registrable
      end

      class Generator < Generator::Base
        identifier :migration
        usage { Registry.usage }

        def call
          (target, content) = Factory.create(*args).call
          write_output(target, content)
        rescue StandardError => e
          raise Command::ArgumentError, e.message
        end
      end

      class Factory
        def self.create(*args)
          clazz = Registry.lookup(*args)
          return clazz.new(*args) if clazz
          raise Command::NotFoundError,
            %Q(Migration for '#{args.join(' ')}' is not supported)
        end
      end

      class Base
        DB_COL_TYPES = {
          string: 'String',
        }

        attr_reader :args

        class << self
          def inherited(child)
            Registry.register(child)
          end

          def identifier(*ids)
            @identifiers = ids.flatten.map(&:to_s)
          end

          def usage(str = nil, &block)
            @usage = str || block
          end
        end

        def initialize(*args)
          @args = args.dup
        end

        def call
          validate_args
          compile_migration_name
          compile_changes
          [target, render]
        rescue StandardError => e
          raise Command::ArgumentError, e.message
        end

        def add_change(change)
          @changes ||= []
          @changes << change if change
        end

        def column_def(str)
          name, type = str.split(':')
          "#{DB_COL_TYPES[type.to_sym]} :#{name.downcase}"
        end

        def target
          raise "Migration filename is nil" unless @name
          "db/migrations/#{timestamp}_#{@name}.rb"
        end

        private

        def timestamp
          DateTime.now.strftime("%Y%m%d%H%M%S")
        end

        def render
          <<~EOS
            Sequel.migration do
              change do
                #{@changes.flatten.join("\n    ")}
              end
            end
          EOS
        end
      end

    end
  end
end

Dir[File.join(__dir__, 'migration', '*.rb')].each { |file| require file }
