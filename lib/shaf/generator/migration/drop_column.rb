module Shaf
  module Generator
    module Migration
      class DropColumn < Base

        identifier %w(drop column)
        usage 'generate migration drop column TABLE_NAME COLUMN_NAME'

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
          "drop_#{column}_from_#{table_name}"
        end

        def compile_changes
          add_change drop_column_change
        end

        def table_name
          args.first
        end

        def column
          args[1]
        end

        def drop_column_change
          [
            "alter_table(:#{table_name}) do",
            "  drop_column :#{column}",
            "end\n"
          ]
        end
      end
    end
  end
end
