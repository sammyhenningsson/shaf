module Shaf
  module Generator
    module Migration
      class Empty < Base

        identifier %r(\A\Z)
        usage 'generate migration [name]'

        def validate_args; end

        def compile_migration_name
          args.first || "empty"
        end

        def compile_changes
          add_change nil
        end
      end
    end
  end
end
