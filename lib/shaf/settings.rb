# frozen_string_literal: true

require 'yaml'
require 'shaf/utils'

module Shaf
  class Settings
    SETTINGS_FILE = 'config/settings.yml'
    DEFAULTS = {
      public_folder: 'frontend/assets',
      views_folder: 'frontend/views',
      documents_dir: 'doc/api',
      migrations_dir: 'db/migrations',
      fixtures_dir: 'spec/fixtures',
      auth_token_header: 'X-Auth-Token',
      paginate_per_page: 25
    }.freeze

    class << self
      def load
        @settings = DEFAULTS.dup
        config = Utils.read_config(SETTINGS_FILE, erb: true)
        @settings.merge! config.fetch(env, {})
      end


      def env
        (ENV['APP_ENV'] || ENV['RACK_ENV'] || 'development').to_sym
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
          @settings[method]
        end
      end

      def define_setter(method)
        key = method[0..-2].to_sym
        define_singleton_method(method) do |arg|
          @settings[key] = arg
        end
      end
    end
  end
end
