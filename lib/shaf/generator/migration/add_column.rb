module Shaf
  module Generator
    module Migration
      class AddColumn < Base

        identifier %w(add column)
        usage 'generate migration add column TABLE_NAME field:type'

        def validate_args
          if (table_name || "").empty?
            raise "Please provide a table and at least " \
              "one column when generation add column migration"
          elsif args.size < 2 || (args[1] || "").empty?
            raise "Please provide at least one column when " \
              "generation add column migration"
          end
        end

        def compile_migration_name
          cols = columns.map { |c| c.split(':').first }
          "add_#{cols.join('_')}_to_#{table_name}"
        end

        def compile_changes
          add_change add_columns_change
        end

        def columns
          args[1..-1]
        end

        def add_columns_change
          cols = columns.map { |s| column_def(s, create: false) }
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
