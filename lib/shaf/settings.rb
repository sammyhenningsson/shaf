# frozen_string_literal: true

require 'yaml'

module Shaf
  class Settings
    SETTINGS_FILE = 'config/settings.yml'

    class << self
      def load
        @settings =
          if File.exist?(SETTINGS_FILE)
            YAML.safe_load(File.read(SETTINGS_FILE))
          else
            {}
          end
      end

      def env
        @env ||= (ENV['APP_ENV'] || ENV['RACK_ENV'] || :development).to_sym
      end

      def method_missing(method, *args)
        load unless defined? @settings

        if method.to_s.end_with? '='
          define_setter(method)
          public_send(method, args.first)
        else
          define_getter(method)
          public_send(method)
        end
      end

      def respond_to_missing?(_method, _include_private = false)
        true
      end

      def define_getter(method)
        define_singleton_method(method) do
          @settings.dig(env.to_s, method.to_s)
        end
      end

      def define_setter(method)
        define_singleton_method(method) do |arg|
          key = method[0..-2]
          @settings[env.to_s] ||= {}
          @settings[env.to_s][key] = arg
        end
      end
    end
  end
end
