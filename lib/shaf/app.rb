require 'shaf/middleware'

module Shaf
  class App
    class << self
      def run!
        app.run!
      end

      def app
        Sinatra.new.tap do |app|
          app.set :port, Settings.port || 3000
          app.use Middleware::RequestId
          app.use Router
        end
      end
    end
  end
end
