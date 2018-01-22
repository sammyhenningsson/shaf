module Shaf
  module Generator
    module Migration
      class CreateTable < Base

        identifier %w(create table)
        usage 'generate migration create table TABLE_NAME [field:type] [..]'

        def validate_args
          return if args.size >= 3
          raise "Please provide a table name when generation a create table migration"
        end

        def compile_migration_name
          @name = "create_#{table_name}_table"
        end

        def table_name
          # FIXME: pluralize correctly!
          name = args[2] || ""
          return "#{name}s" unless name.empty?
          raise Command::ArgumentError, "Table name must be given"
        end

        def compile_changes
          add_change create_table_change
        end

        def create_table_change
          cols = ["primary_key :id"]
          cols += args[3..-1].map { |s| column_def(s) }
          [
            "create_table(:#{table_name}) do",
            *cols.map { |col| col.prepend("  ") }, # indent body with 2 spaces
            "end\n\n"
          ]
        end

      end
    end
  end
end
