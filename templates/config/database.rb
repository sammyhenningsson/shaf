require 'sinatra/base'
require 'sequel'
require 'config/constants'
require 'fileutils'

CONFIG = {

  production: {
    adapter: 'postgres',
    host: ENV['SHAF_DB_HOST'],
    database: ENV['SHAF_DB_NAME'],
    user: ENV['SHAF_DB_USER'],
    password: ENV['SHAF_DB_PASS']
  }.freeze,

  development: {
    adapter: 'postgres',
    host: ENV['SHAF_DB_HOST'],
    database: ENV['SHAF_DB_NAME'] || 'shaf_dev',
    user: ENV['SHAF_DB_USER'] || 'shaf',
    password: ENV['SHAF_DB_PASS']
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

