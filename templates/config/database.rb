# frozen_string_literal: true

require 'sinatra/base'
require 'sequel'
require 'fileutils'

config = {

  production: {
    adapter: 'postgres',
    host: ENV['SHAF_DB_HOST'],
    database: ENV['SHAF_DB_NAME'],
    user: ENV['SHAF_DB_USER'],
    password: ENV['SHAF_DB_PASS']
  }.freeze,

  development: {
    adapter: 'sqlite',
    database: 'db/development.sqlite3'
  }.freeze,

  test: {
    adapter: 'sqlite',
    database: 'db/test.sqlite3'
  }.freeze

}.freeze

env = Sinatra::Application.settings.environment

unless config[env]
  STDERR.puts "No Database config for environment '#{env}'"
  exit 1
end

migrations_dir = 'db/migrations'
FileUtils.mkdir_p(migrations_dir) unless Dir.exist?(migrations_dir)

DB = Sequel.connect(config[env])
