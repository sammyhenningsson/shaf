require 'sequel'
require 'config/database'

Sequel.extension :migration
return unless Dir[File.join(MIGRATIONS_DIR, "*")].any?
return if Sequel::Migrator.is_current?(DB, MIGRATIONS_DIR)

environment = ENV['RACK_ENV']

if environment == 'test'
  $logger.info "Running migrations in 'test' environment.."
  Sequel::Migrator.run(DB, "#{APP_ROOT}/db/migrations")
else
  msg = "Database for environment '#{environment}' is not " \
    "updated to the latest migration"
  STDERR.puts msg
  $logger&.warn msg
end
