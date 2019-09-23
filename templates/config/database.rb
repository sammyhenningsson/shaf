# frozen_string_literal: true

require 'sequel'
require 'fileutils'
require 'yaml'
require 'shaf/utils'

class Database
  CONFIG_FILE = File.expand_path("../database.yml", __FILE__)
  MIGRATIONS_DIR = 'db/migrations'

  class << self
    def get_connection
      ensure_config
      ensure_migrations_dir

      connect
    end

    def config
      @config ||= Shaf::Utils.read_config(CONFIG_FILE, erb: true)
    end

    def env
      Shaf::Utils.environment
    end

    def connect
      Sequel.connect config[env]
    end

    def ensure_config
      return if config[env]
      STDERR.puts "No Database config for environment '#{env}'"
      exit 1
    end

    def ensure_migrations_dir
      return if Dir.exist?(MIGRATIONS_DIR)
      FileUtils.mkdir_p(MIGRATIONS_DIR)
    end
  end
end

DB = Database.get_connection
