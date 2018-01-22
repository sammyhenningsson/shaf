module Shaf
  module Generator
    module Migration
      class AddColumn < Base

        identifier %w(add column)
        usage 'generate migration add column TABLE_NAME [field:type] [..]]'

        def validate_args
          return if args.size >= 4
          raise "Please provide a table and at least one column " \
            "when generation add column migration"
        end

        def compile_migration_name
          cols = columns.map { |c| c.split(':').first }
          "add_#{cols.join('_')}_to_#{table_name}"
        end

        def table_name
          name = args[2] || ""
          return name unless name.empty?
          raise Command::ArgumentError, "Table name must be given"
        end

        def compile_changes
          add_change add_columns_change
        end

        def columns
          args[3..-1]
        end

        def add_columns_change
          cols = columns.map do |s|
            "add_column #{column_def(s, create: false)}"
          end
          [
            "alter_table(:#{table_name}) do",
            *cols.map { |col| col.prepend("  ") }, # indent body with 2 spaces
            "end\n"
          ]
        end
      end
    end
  end
end
