namespace :db do
  desc "Prints current schema version"
  task :version do
    require 'config/database'
    if DB.tables.include?(:schema_migrations)
      migration = DB[:schema_migrations].first
      filename = migration && migration[:filename]
      if match = /(\d*)_(.*).rb/.match(filename)
        puts "Schema version: #{match[1]} (#{match[2]})"
      else
        puts "No migration found"
      end
    else
      puts "No schema_info table"
    end
  end

  desc "Prints all schema versions"
  task :versions do
    require 'config/database'
    if DB.tables.include?(:schema_migrations)
      DB[:schema_migrations].each do |migration|
        filename = migration && migration[:filename]
        if match = /(\d*)_(.*).rb/.match(filename)
          puts "#{match[1]}: #{match[2]}"
        end
      end
    else
      puts "No schema_info table"
    end
  end

  desc "Run migrations"
  task :migrate, [:version] do |t, args|
    require 'config/database'
    Sequel.extension :migration
    if args[:version]
      puts "Migrating to version #{args[:version]}"
      Sequel::Migrator.run(DB, MIGRATIONS_DIR, target: args[:version].to_i)
    else
      puts "Migrating to latest"
      Sequel::Migrator.run(DB, MIGRATIONS_DIR)
    end
  end

  desc "Perform rollback to specified target or full rollback as default"
  task :rollback, :target do |t, args|
    args.with_defaults(target: 0)
    require 'config/database'
    Sequel.extension :migration
    Sequel::Migrator.run(DB, MIGRATIONS_DIR, target: args[:target].to_i)
  end

  Rake::Task["db:migrate"].enhance do
    Rake::Task["db:version"].invoke
  end

  Rake::Task["db:rollback"].enhance do
    Rake::Task["db:version"].invoke
  end

  desc "Create an empty migration"
  namespace :create do
    task :migration, [:name] do |t, args|
      require 'date'
      require 'sinatra/base'
      require 'sequel'
      require 'config/database'
      timestamp = DateTime.now.strftime("%Y%m%d%H%M%S")
      filename = "#{MIGRATIONS_DIR}/#{timestamp}_#{args[:name]}.rb"
      File.write filename, <<~EOS
      Sequel.migration do
        change do
        end
      end
      EOS
      puts "Created file: #{filename}"
    end
  end
end
