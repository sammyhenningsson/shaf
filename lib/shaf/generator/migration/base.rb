require 'date'
require 'shaf/generator/migration/types'

module Shaf
  module Generator
    module Migration
      class Base
        attr_reader :args, :options

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

        def initialize(*args, **options)
          @args = args
          @options = options
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
          _, col_type = str.split(':')
          type = Type.find(col_type)
          raise "No supported DB column types for: #{col_type}" unless type
          type.build(str, create: create, alter: !create)
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

        def render
          <<~RUBY
            Sequel.migration do
              change do
                #{@changes.flatten.join("\n    ")}
              end
            end
          RUBY
        end
      end

    end
  end
end
