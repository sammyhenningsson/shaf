module Shaf
  module Generator
    module Migration
      class AddIndex < Base

        identifier %w(add index)
        usage 'generate migration add index TABLE_NAME COLUMN_NAME'

        def validate_args
          if (table_name || "").empty? || (column || "").empty?
            raise "Please provide a table and the column to create index on"
          end
        end

        def compile_migration_name
          "add_#{column}_index_to_#{table_name}"
        end

        def table_name
          args.first
        end

        def compile_changes
          add_change add_index_change
        end

        def column
          args[1]
        end

        def add_index_change
          col_def =  column_def("#{column}:index", create: false)
          [
            "alter_table(:#{table_name}) do",
            col_def.prepend("  "), # indent body with 2 spaces
            "end\n"
          ]
        end
      end
    end
  end
end
