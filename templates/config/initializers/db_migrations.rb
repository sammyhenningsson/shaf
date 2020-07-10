require 'sequel'
require 'config/database'

Sequel.extension :migration

class DbMigrations
  def self.verify
    new.verify
  end

  def verify
    return if fully_migrated?
    run_migrations? ? migrate : show_warning
  end

  def fully_migrated?
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

  def run_migrations?
    environment == 'test'
  end

  def migrate
    Shaf.log.info "Running migrations in #{environment} environment.."
    Sequel::Migrator.run(DB, migrations_dir)
  end

  def show_warning
    msg = "Database for environment '#{environment}' is not " \
      'updated to the latest migration'
    STDERR.puts msg
    Shaf.log.warn msg
  end
end

DbMigrations.verify
