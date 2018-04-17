Shaf::DbTask.new(:version, description: "Prints current schema version") do
  if migrations.any?
    version, filename = extract_version_and_filename(last_migration)
    puts "Schema version: #{version} (#{filename})"
  else
    puts "No migrations found"
  end
end

Shaf::DbTask.new(:versions, description: "Prints all schema versions") do
  if migrations.any?
    migrations.each do |migration|
      version, filename = extract_version_and_filename(migration)
      next unless version && filename
      puts "#{version}: #{filename}"
    end
  else
    puts "No migrations found"
  end
end

Shaf::DbTask.new(:migrate, description: "Run migrations", args: [:version]) do |t, args|
  if args[:version]
    puts "Migrating to version #{args[:version]}"
    Sequel::Migrator.run(DB, MIGRATIONS_DIR, target: args[:version].to_i)
  else
    puts "Migrating to latest"
    Sequel::Migrator.run(DB, MIGRATIONS_DIR)
  end
end

Shaf::DbTask.new(
  :rollback,
  description: "Perform rollback to specified number of steps back or to the previous version",
  args: [:target]
) do |t, args|

  args.with_defaults(target: 1)
  target = -(args[:target].to_i + 1)
  target = 0 if -target > migrations.size
  migration = migrations.dig(target, :filename)
  version, _ = extract_version_and_filename(migration)

  warn_if_rolling_back_more_than = 5
  if target == 0 || -target > warn_if_rolling_back_more_than
    puts "This would migrate the Database to version: #{version}. Continue [N/y]?"
    next unless /\Ay/i =~ STDIN.gets.chomp&.downcase
  end
  Sequel::Migrator.run(DB, MIGRATIONS_DIR, target: version.to_i)
end

Rake::Task["db:migrate"].enhance do
  Rake::Task["db:version"].invoke
end

Rake::Task["db:rollback"].enhance do
  Rake::Task["db:version"].invoke
end

Shaf::DbTask.new(:reset, description: "Reset the database by deleting all rows in all columns") do
  version = 0
  Sequel::Migrator.run(DB, MIGRATIONS_DIR, target: version)
  Sequel::Migrator.run(DB, MIGRATIONS_DIR)
end

Shaf::DbTask.new(:seed, description: "Seed the Database") do
  ENV['RACK_ENV'] ||= 'development'
  require 'config/bootstrap'

  if File.exist? "db/seeds.rb"
    require "db/seeds"
  end

  if Dir.exist? "db/seeds"
    Dir['db/seeds/**/*.rb'].each do |file|
      require file.sub(".rb", "")
    end
  end
end
