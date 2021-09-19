# frozen_string_literal: true

require 'set'
require 'sinatra'
require 'shaf/errors'

module Shaf
  class Router
    class MethodNotAllowedResponder
      attr_reader :supported_methods

      def initialize(supported_methods)
        @supported_methods = supported_methods
      end

      def allowed
        supported_methods.join(', ')
      end

      def call(env)
        [405, {'Allow' => allowed}, '']
      end
    end

    class NullController
      def call(env)
        request = request(env)
        responder = Responder.for(request, error)
        responder.call(self, error)

        response.finish
      end

      # Called from responder
      def content_type(mime)
        response["Content-Type"] = mime
      end

      # Called from responder
      def body(body)
        response.body  = body
      end

      private

      def status
        500
      end

      def request(env)
        Sinatra::Request.new(env)
      end

      def response
        @response ||= Sinatra::Response.new(nil, status)
      end

      def error
        @error ||= Errors::ServerError.new(
          'Internal error: No controller has been mounted on Router',
          code: 'NO_MOUNTED_CONTROLLERS',
          title: 'Shaf::Router must have at least one mounted controller',
        )
      end
    end

    class << self
      def mount(controller, default: false)
        @default_controller = controller if default
        controllers << controller
      end

      def routes
        @routes ||= init_routes
      end

      # This controller will be used when no other can handle the request
      # (E.g. returning 404 Not Found)
      def default_controller
        @default_controller ||= nil
      end

      private

      def controllers
        @controllers ||= []
      end

      def init_routes
        routes = Hash.new do |hash, key|
          hash[key] = Hash.new { |h, k| h[k] = Set.new }
        end
        controllers.each { |controller| init(controller, routes) }
        routes
      end

      def init(controller, routes)
        controller.routes.each do |method, controller_routes|
          routes[method][controller] += controller_routes.map(&:first)
        end
      end
    end

    def initialize(app = NullController.new)
      @app = app
    end

    def call(env)
      # When the api is mounted in Rails then the mount point will be not be
      # present in PATH_INFO but it will instead be available in SCRIPT_NAME
      # Shaf need to know about the full path in order to make all path helpers
      # work, so we need to add the mountpoint back to PATH_INFO.
      unless String(env['SCRIPT_NAME']).empty?
        env['PATH_INFO'] = '' if env['PATH_INFO'] == '/'
        env['PATH_INFO'] = "#{env['SCRIPT_NAME']}#{env['PATH_INFO']}"
      end

      http_method, path = http_details(env)

      result = nil

      each_controller_for(http_method, path) do |controller|
        result = controller.call(env)
        break unless cascade? result
      end

      result
    end

    private

    def http_details(env)
      [env['REQUEST_METHOD'], env['PATH_INFO']]
    end

    def each_controller_for(http_method, path)
      find_cached(http_method, path).each { |ctrlr| yield ctrlr }

      if controller = find(http_method, path)
        yield controller
      end

      find_all(http_method, path).each do |ctrlr|
        yield ctrlr unless ctrlr == controller
      end

      supported_methods = supported_methods_for(path)
      if !supported_methods.empty? && !supported_methods.include?(http_method)
        yield MethodNotAllowedResponder.new(supported_methods)
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

    def supported_methods_for(path)
      methods = Set.new
      routes.each do |http_method, controllers|
        controllers.each do |_, patterns|
          next unless patterns.any? { |pattern| pattern.match(path) }
          methods << http_method
        end
      end
      methods.to_a
    end

    def cascade?(result)
      result.dig(1, 'X-Cascade') == 'pass'
    end

    def cache
      @cache ||= Hash.new { |hash, key| hash[key] = Set.new }
    end

    def add_cache(controller, http_method, path)
      return unless controller

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
