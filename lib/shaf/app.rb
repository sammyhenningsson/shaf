require 'shaf/middleware'

module Shaf
  class App
    class << self
      def instance
        create_instance unless defined?(@instance)
        @instance
      end

      def create_instance
        @instance = Sinatra.new
        @instance.set :port, Settings.port || 3000
        @instance.use Shaf::Middleware::RequestId
      end

      def use(middleware)
        instance.use middleware
      end
    end
  end
end
