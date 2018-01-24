require 'date'

module Shaf
  module Generator
    module Migration

      class Factory
        extend RegistrableFactory
      end

      class Generator < Generator::Base
        identifier :migration
        usage { Factory.usage }

        def call
          (target, content) = Factory.create(*args).call
          write_output(target, content)
        rescue StandardError => e
          raise Command::ArgumentError, e.message
        end
      end

      class Base
        DB_COL_TYPES = {
          integer:    ['Integer :%s', ':%s, Integer'],
          varchar:    ['String %s', ':%s, String'],
          string:     ['String :%s', ':%s, String'],
          text:       ['String :%s, text: true', ':%s, String, text: true'],
          blob:       ['File :%s', ':%s, File'],
          bigint:     ['Bignum :%s', ':%s, Bignum'],
          double:     ['Float :%s', ':%s, Float'],
          numeric:    ['BigDecimal :%s', ':%s, BigDecimal'],
          date:       ['Date :%s', ':%s, Date'],
          timestamp:  ['DateTime :%s', ':%s, DateTime'],
          time:       ['Time :%s', ':%s, Time'],
          bool:       ['TrueClass :%s', ':%s, TrueClass'],
          boolean:    ['TrueClass :%s', ':%s, TrueClass'],
        }

        attr_reader :args

        class << self
          def inherited(child)
            Factory.register(child)
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
          name = compile_migration_name
          compile_changes
          [target(name), render]
        rescue StandardError => e
          raise Command::ArgumentError, e.message
        end

        def add_change(change)
          @changes ||= []
          @changes << change if change
        end

        def db_type(type)
          type ||= :string
          DB_COL_TYPES[type.to_sym] or raise "Column type '#{type}' not supported"
        end

        def column_def(str, create: true)
          name, type = str.split(':')
          format db_type(type)[create ? 0 : 1], name.downcase
        end

        def target(name)
          raise "Migration filename is nil" unless name
          "db/migrations/#{timestamp}_#{name}.rb"
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
