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
          generator = args.empty? ? Empty.new : Factory.create(*args)
          (target, content) = generator.call
          write_output(target, content)
        rescue StandardError => e
          raise Command::ArgumentError, e.message
        end
      end

      class Base
        DB_COL_FORMAT_STRINGS = {
          integer:    ['Integer :%s',             'add_column :%s, Integer'],
          varchar:    ['String %s',               'add_column :%s, String'],
          string:     ['String :%s',              'add_column :%s, String'],
          text:       ['String :%s, text: true',  'add_column :%s, String, text: true'],
          blob:       ['File :%s',                'add_column :%s, File'],
          bigint:     ['Bignum :%s',              'add_column :%s, Bignum'],
          double:     ['Float :%s',               'add_column :%s, Float'],
          numeric:    ['BigDecimal :%s',          'add_column :%s, BigDecimal'],
          date:       ['Date :%s',                'add_column :%s, Date'],
          timestamp:  ['DateTime :%s',            'add_column :%s, DateTime'],
          time:       ['Time :%s',                'add_column :%s, Time'],
          bool:       ['TrueClass :%s',           'add_column :%s, TrueClass'],
          boolean:    ['TrueClass :%s',           'add_column :%s, TrueClass'],
          index:      ['index :%s, unique: true', 'add_index :%s'],
        }

        REGEXP_DB_TYPES = {
          /\Aforeign_key\((\w+)\)/ => ['foreign_key :%s, :\1', 'add_foreign_key :%s, :\1'],
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

        def column_def(str, create: true)
          name, type = str.split(':')
          format_string = db_format_string(type, create ? 0 : 1)
          format format_string, name.downcase
        end

        def target(name)
          raise "Migration filename is nil" unless name
          "db/migrations/#{timestamp}_#{name}.rb"
        end

        private

        def timestamp
          DateTime.now.strftime("%Y%m%d%H%M%S")
        end

        def add_timestamp_columns?
          if File.exist? 'config/initializers/sequel.rb'
            require 'config/initializers/sequel'
            Sequel::Model.plugins.include? Sequel::Plugins::Timestamps
          end
        end

        def db_format_string(type, range = 0..1)
          type ||= :string
          result = DB_COL_FORMAT_STRINGS[type.to_sym]
          result ||= regexp_db_format_string(type)
          raise "Column type '#{type}' not supported" unless result
          result[range]
        end

        def regexp_db_format_string(type)
          REGEXP_DB_TYPES.each do |pattern, strings|
            m = pattern.match(type) or next
            return strings.map { |a| replace_backreferences(m, a) }
          end
        end

        def replace_backreferences(match, str)
          groups = match.size
          (1...groups).inject(str) do |s, i|
            s.gsub("\\#{i}", match[i])
          end
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

require 'shaf/generator/migration/add_column'
require 'shaf/generator/migration/add_index'
require 'shaf/generator/migration/create_table'
require 'shaf/generator/migration/drop_column'
require 'shaf/generator/migration/empty'
require 'shaf/generator/migration/rename_column'
