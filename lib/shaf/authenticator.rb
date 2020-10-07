require 'set'
require 'digest'
require 'shaf/authenticator/request'

module Shaf
  module Authenticator
    class << self
      def register(authenticator)
        authenticators << authenticator
      end

      def unregister(authenticator)
        authenticators.delete_if { |auth| auth == authenticator }
      end

      def challenges_for(realm: nil)
        authenticators.each_with_object([]) do |authenticator, challenges|
          challenges.concat Array(authenticator.challenges_for(realm))
        end
      end

      def user(env, realm: nil)
        request = Request.new(env)
        return unless request.provided?

        authenticator = authenticator_for(request)
        authenticator&.user(request, realm: realm)
      end

      private

      def authenticators
        @authenticators ||= Set.new
      end

      def authenticator_for(request)
        scheme = request.scheme
        authenticator = authenticators.find { |auth| auth.scheme? scheme }

        logger.warn(
          "Client tried to authenticate with an unsupported " \
          "authentication scheme: #{scheme}"
        ) unless authenticator

        authenticator
      end

      def logger
        Shaf.logger
      end
    end
  end
end

require 'shaf/authenticator/base'
require 'shaf/authenticator/basic_auth'
