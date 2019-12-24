require 'rack/auth/abstract/request'

module Shaf
  module Authenticator
    class Request < Rack::Auth::AbstractRequest
      attr_reader :env

      def valid?
        !String(authorization).strip.empty?
      end

      def authorization
        env[authorization_key]
      end
    end
  end
end
