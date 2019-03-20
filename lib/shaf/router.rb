# frozen_string_literal: true

require 'shaf/middleware'
require 'set'

module Shaf
  class Router
    class << self
      def mount(controller, default: false)
        @default_controller = controller if default
        @controllers ||= []
        @controllers << controller
      end

      def routes
        init_routes unless defined? @routes
        @routes
      end

      # This controller will be used when no other can handle the request
      # (E.g. returning 404 Not Found)
      def default_controller
        @default_controller ||= nil
      end

      private

      attr_reader :controllers

      def init_routes
        @routes = {}
        controllers.each { |controller| init_routes_for(controller) }
      end

      def init_routes_for(controller)
        controller.routes.each do |method, controller_routes|
          routes[method] ||= Hash.new { |hash, key| hash[key] = [] }
          routes[method][controller] += controller_routes.map(&:first)
        end
      end
    end

    def initialize(app)
      @app = app
    end

    def call(env)
      http_method, path = http_details(env)

      result = nil

      controllers_for(http_method, path) do |controller|
        result = controller.call(env)
        break unless cascade? result
      end

      result
    end

    private

    def http_details(env)
      [env['REQUEST_METHOD'], env['PATH_INFO']]
    end

    def controllers_for(http_method, path)
      find_cached(http_method, path).each { |ctrlr| yield ctrlr }

      if controller = find(http_method, path)
        yield controller
      end

      find_all(http_method, path).each do |ctrlr|
        yield ctrlr unless ctrlr == controller
      end

      yield default_controller
    end

    def default_controller
      self.class.default_controller || @app || raise('No default controller')
    end

    def routes
      self.class.routes
    end

    def find(http_method, path)
      routes[http_method].each do |controller, patterns|
        next unless patterns.any? { |pattern| pattern.match(path) }
        add_cache(controller, http_method, path)
        return controller
      end

      nil
    end

    def find_all(http_method, path)
      Set.new.tap do |controllers|
        routes[http_method].each do |ctrlr, patterns|
          next unless patterns.any? { |pattern| pattern.match(path) }
          add_cache(ctrlr, http_method, path)
          controllers << ctrlr
        end
      end
    end

    def cascade?(result)
      result.dig(1, 'X-Cascade') == 'pass'
    end

    def cache
      @cache ||= Hash.new { |hash, key| hash[key] = Set.new }
    end

    def add_cache(controller, http_method, path)
      key = cache_key(http_method, path)
      cache[key] << controller
    end

    def find_cached(http_method, path)
      key = cache_key(http_method, path)
      cache[key]
    end

    def cache_key(http_method, path)
      path[1..-1].split('/').inject("#{http_method}_") do |key, segment|
        segment = ':id' if segment =~ /\A\d+\z/
        "#{key}/#{segment}"
      end
    end
  end
end
