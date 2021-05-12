require 'sinatra'

module Shaf
  class App
    class << self
      # Either call `Shaf::App.run!`
      def run!
        instance.run!
      end

      # Or `run Shaf::App` (in config.ru)
      def call(*args)
        instance.call(*args)
      end

      def instance
        # This works since Sinatra includes Sinatra::Delegator into
        # Rack::Builder, which means that Rack::Builder#set will be delegated
        # to Sinatra::Application
        @instance ||= Rack::Builder.new(app) do
          set :port, Settings.port || 3000
        end
      end

      def use(middleware, *args, **kwargs, &block)
        if args.empty? && kwargs.empty?
          instance.use middleware, &block
        elsif kwargs.empty?
          instance.use middleware, *args, &block
        elsif args.empty?
          instance.use middleware, **kwargs, &block
        else
          instance.use middleware, *args, **kwargs, &block
        end
      end

      private

      def app
        Router.new
      end
    end
  end
end
