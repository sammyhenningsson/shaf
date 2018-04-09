module Shaf
  module Tasks
    class DbTask
      include Rake::DSL

      def initialize(name, description:, args: [], &block)
        @name = name
        @desc = description
        @args = args
        @block = block
        define_task
      end

      def define_task
        namespace :db do
          desc @desc
          task @name, @args do |t, args|
            require 'config/database'
            Sequel.extension :migration
            instance_exec(t, args, &@block)
          end
        end
      end

      def migrations
        @migrations ||= DB[:schema_migrations].all
      end

      def last_migration
        DB[:schema_migrations].order(:filename).last
      end

      def extract_version_and_filename(filename)
        return [] unless filename
        filename = filename[:filename] if filename.is_a? Hash
        match = /(\d*)_(.*).rb/.match(filename)
        return [] unless match
        match[1..2]
      end
    end
  end
end
