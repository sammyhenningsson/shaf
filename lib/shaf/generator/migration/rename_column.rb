module Shaf
  module Generator
    module Migration
      class RenameColumn < Base

        identifier %w(rename column)
        usage 'generate migration rename column TABLE_NAME OLD_NAME NEW_NAME'

        def validate_args
          if table_name.empty?
            raise "Please provide a table and at least " \
              "one column when generation add column migration"
          elsif from_col.empty? || to_col.empty?
            raise "Please provide the old column name and the new column name"
          end
        end

        def compile_migration_name
          "rename_#{table_name}_#{from_col}_to_#{to_col}"
        end

        def compile_changes
          add_change rename_column_change
        end

        def from_col
          args[1] || ""
        end

        def to_col
          args[2] || ""
        end

        def rename_column_change
          [
            "alter_table(:#{table_name}) do",
            "  rename_column :#{from_col}, :#{to_col}",
            "end\n"
          ]
        end
      end
    end
  end
end
