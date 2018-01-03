require 'sequel'
require 'config/database'

Sequel.extension :migration
unless Sequel::Migrator.is_current?(DB, MIGRATIONS_DIR)
  if ENV['RACK_ENV'] == 'test'
    $logger.info "Running migrations in 'test' environment.."
    Sequel::Migrator.run(DB, "#{APP_ROOT}/db/migrations")
  else
    environment = Sinatra::Application.settings.environment
    msg = "Database for environment '#{environment}' is not " \
      "updated to the latest migration"
    STDERR.puts msg
    $logger&.warn msg
  end
end
