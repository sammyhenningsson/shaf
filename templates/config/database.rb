require 'sinatra/base'
require 'sequel'
require 'config/constants'
require 'fileutils'

CONFIG = {

  production: {
    adapter: 'postgres',
    host: ENV['SPOC_DB_HOST'],
    database: ENV['SPOC_DB_USER'],
    user: ENV['SPOC_DB_USER'],
    password: ENV['SPOC_DB_PASS']
  }.freeze,

  development: {
    adapter: 'postgres',
    host: ENV['SPOC_DB_HOST'],
    database: ENV['SPOC_DB_USER'] || 'spoc_dev',
    user: ENV['SPOC_DB_USER'] || 'spoc',
    password: ENV['SPOC_DB_PASS']
  }.freeze,

  test: {
    adapter: 'sqlite',
    database: File.join(APP_ROOT, 'db', 'test.sqlite3'),
  }.freeze

}.freeze


env = Sinatra::Application.settings.environment

unless CONFIG[env]
  STDERR.puts "No Database config for environment '#{env}'"
  exit 1
end

MIGRATIONS_DIR = File.join(APP_ROOT, 'db', 'migrations')
FileUtils.mkdir_p(MIGRATIONS_DIR) unless Dir.exist?(MIGRATIONS_DIR)

DB = Sequel.connect(CONFIG[env])

