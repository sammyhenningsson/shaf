require 'sequel'
require 'config/database'

Sequel.extension :migration

def current?
  return true unless Dir[migrations_dir_glob].any?
  Sequel::Migrator.is_current?(DB, migrations_dir)
end

def migrations_dir
  File.join(Shaf::Settings.app_root, Shaf::Settings.migrations_dir)
end

def migrations_dir_glob
  File.join(migrations_dir, '*')
end

def environment
  ENV['RACK_ENV']
end

def init
  return if current?

  if environment == 'test'
    $logger.info "Running migrations in 'test' environment.."
    Sequel::Migrator.run(DB, migrations_dir)
  else
    msg = "Database for environment '#{environment}' is not " \
      'updated to the latest migration'
    STDERR.puts msg
    $logger&.warn msg
  end
end

init
