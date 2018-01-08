require 'date'

module Shaf
  module Generator
    class Migration < Base

      TEMPLATE_NAME = "db_migration.rb".freeze
      DB_COL_TYPES = {
        string: 'String',
      }

      identifier :migration
      usage [
        'generate migration [create table TABLE_NAME [field:type] [..]]',
        #'generate migration [create index INDEX_NAME table [field [..]]'
      ]

      def call
        process_args
        write_output(target, render)
      rescue StandardError => e
        raise Command::ArgumentError, e.message
      end

      def target(*args)
        raise "Target filename is nil" unless @output_file
        "db/migrations/#{@output_file}"
      end

      private

      def process_args
        respond_to?(action, true) ? send(action) : empty
      rescue StandardError => e
        raise "Generate failed: #{e.message}"
      end

      def action
        (args.first || "").downcase.to_sym
      end

      def add_change(change)
        @changes ||= []
        @changes << change if change
      end

      def name=(name)
        @output_file = "#{timestamp}_#{name}.rb"
      end

      def timestamp
        DateTime.now.strftime("%Y%m%d%H%M%S")
      end

      def empty
        self.name = args.first || "unnamed"
      end

      def create
        if args.size < 3
          raise "Sub command [table|index] and NAME must be given!"
        end

        case args[1].downcase
        when 'table'
          self.name = "create_#{table_name}_table"
          add_change create_table
        when 'index'
          raise "create #{args[1]} is not implemented"
        else
          raise %Q(Don't know how to generate '#{args[1]}')
        end
      end

      def table_name
        # FIXME: pluralize correctly!
        name = args[2] || ""
        return "#{name}s" unless name.empty?
        raise Command::ArgumentError, "table name must be given"
      end

      def create_table
        cols = ["primary_key :id"]
        cols += args[3..-1].map { |s| column_def(s) }
        {
          op: :create_table,
          table_name: table_name,
          columns: cols
        }
      end

      def column_def(str)
        name, type = str.split(':')
        "#{DB_COL_TYPES[type.to_sym]} :#{name.downcase}"
      end

      def render
        <<~EOS
          Sequel.migration do
            change do
              #{@changes.map { |c| render_change(c) }.join("\n    ")}
            end
          end
        EOS
      end

      def render_change(c)
        if c.fetch(:op) == :create_table
          [
            "create_table(:#{c.fetch(:table_name)}) do",
            *c.fetch(:columns).map { |col| col.prepend("  ") }, # 2 space indent
            "end\n"
          ]
        end
      end
    end
  end
end
