namespace :db do
  desc "Prints current schema version"
  task :version do
    require 'config/database'
    if DB.tables.include?(:schema_migrations)
      migration = DB[:schema_migrations].order(:filename).last
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

  desc "Perform rollback to specified number of steps back or to the previous version"
  task :rollback, :target do |t, args|
    args.with_defaults(target: 1)
    require 'config/database'
    Sequel.extension :migration
    all_migrations = DB[:schema_migrations].all
    target = -(args[:target].to_i + 1)
    target = 0 if -target > all_migrations.size
    filename = all_migrations.dig(target, :filename)
    version = filename[/(\d*)_.*.rb/, 1].to_i

    warn_if_rolling_back_more_than = 5
    if target == 0 || -target > warn_if_rolling_back_more_than
      puts "This would migrate the Database to version: #{version}. Continue [N/y]?"
      next unless /\Ay/i =~ STDIN.gets.chomp&.downcase
    end
    Sequel::Migrator.run(DB, MIGRATIONS_DIR, target: version)
  end

  Rake::Task["db:migrate"].enhance do
    Rake::Task["db:version"].invoke
  end

  Rake::Task["db:rollback"].enhance do
    Rake::Task["db:version"].invoke
  end
end
