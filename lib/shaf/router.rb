# frozen_string_literal: true

require 'shaf/middleware'

module Shaf
  class Router
    class << self
      def mount(controller, default: false)
        @default = controller if default
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
        @default || raise('No default controller')
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

    # We don't care about the sinatra app created in Shaf::App::app
    # We just want it to start the server and handle middleware.
    # After that Shaf::Router will handle the rest.
    def initialize(_app); end

    def call(env)
      method, path = http_details(env)
      controller_for(method, path).call(env)
    end

    private

    def http_details(env)
      [env['REQUEST_METHOD'], env['PATH_INFO']]
    end

    def controller_for(http_method, path)
      #cached = find_cached(http_method, path)
      lookup(http_method, path) || default_controller
    end

    def lookup(http_method, path)
      self.class.routes[http_method].find do |controller, patterns|
        next unless patterns.any? { |pattern| pattern.match(path) }
        #add_cache(controller, http_method, path)
        break controller
      end
    end

    def default_controller
      self.class.default_controller
    end
  end
end
