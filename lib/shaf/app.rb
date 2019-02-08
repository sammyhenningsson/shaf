require 'shaf/middleware'

module Shaf
  class App
    class << self
      def instance
        @instance ||= create_instance
      end

      def create_instance
        Sinatra.new.tap do |instance|
          instance.set :port, Settings.port || 3000
          instance.use Shaf::Middleware::RequestId
        end
      end

      def use(middleware)
        instance.use middleware
      end
    end
  end
end
