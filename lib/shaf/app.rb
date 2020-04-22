require 'shaf/middleware'

module Shaf
  class App
    class << self
      # Either call `Shaf::App.run!`
      def run!
        app.run!
      end

      # Or `run Shaf::App` (in config.ru)
      def call(*args)
        app.call(*args)
      end

      def app
        @app ||=
          Sinatra.new.tap do |app|
            app.set :port, Settings.port || 3000
            app.use Middleware::RequestId
            app.use Router
          end
      end
    end
  end
end
