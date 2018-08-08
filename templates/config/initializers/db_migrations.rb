require 'sequel'
require 'config/database'

Sequel.extension :migration
Dir[File.join(MIGRATIONS_DIR, "*")]

def is_current?
  return true unless Dir[File.join(MIGRATIONS_DIR, "*")].any?
  Sequel::Migrator.is_current?(DB, MIGRATIONS_DIR)
end

def environment
  ENV['RACK_ENV']
end

def init
  return if is_current?

  if environment == 'test'
    $logger.info "Running migrations in 'test' environment.."
    Sequel::Migrator.run(DB, "#{APP_ROOT}/db/migrations")
  else
    msg = "Database for environment '#{environment}' is not " \
      "updated to the latest migration"
    STDERR.puts msg
    $logger&.warn msg
  end
end

init

