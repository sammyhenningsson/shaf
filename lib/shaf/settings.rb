require 'yaml'


module Shaf
  class Settings
    SETTINGS_FILE = 'config/settings.yml'

    class << self
      def load
        @settings = File.exist?(SETTINGS_FILE) ?
          YAML.load(File.read(SETTINGS_FILE)) : {}
      end

      def env
        @env ||= (ENV['APP_ENV'] || ENV['RACK_ENV'] || :development).to_sym
      end

      def method_missing(method, *args)
        load unless defined? @settings

        define_singleton_method(method) do
          @settings.dig(env.to_s, method.to_s)
        end

        return public_send(method)
      end

      def respond_to_missing?(method, include_private = false)
        return true
      end
    end
  end
end
