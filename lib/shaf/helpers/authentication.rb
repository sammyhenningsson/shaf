# frozen_string_literal: true

require 'set'
require 'shaf/authenticator'
require 'shaf/errors'

module Shaf
  module Authentication
    class NoChallengesError < Error
      def initialize(realm)
        # FIXME: discribe how to specify challenges
        super("No Authentication challenges for realm: #{realm}")
      end
    end

    def www_authenticate(realm: nil)
      challenges = Authenticator.challenges_for(realm: realm)
      raise NoChallengesError.new(realm) if challenges.empty?

      list = challenges.map(&:to_s)
      return if list.empty?

      headers 'WWW-Authenticate' => list
    end

    def authenticate!(realm: nil)
      user = current_user(realm: realm)
      return user if user

      www_authenticate(realm: realm)
      msg = "Unauthorized action"
      msg += " (Realm: #{realm})" if realm
      raise Shaf::Errors::UnauthorizedError, msg
    end

    alias current_user! authenticate!

    def current_user(realm: nil)
      @current_user ||= {}
      @current_user[realm] ||= Authenticator.user(request.env, realm: realm)
    end
  end
end
