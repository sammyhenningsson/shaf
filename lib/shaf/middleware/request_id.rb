require 'securerandom'

module Shaf
  module Middleware
    class RequestId
      def initialize(app)
        @app = app
      end

      def call(env)
        env["REQUEST_ID"] = SecureRandom.uuid
        @app.call(env)
      end
    end
  end
end
