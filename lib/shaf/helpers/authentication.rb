# frozen_string_literal: true

require 'set'
require 'shaf/authenticator'
require 'shaf/errors'

module Shaf
  module Authentication
    class NoChallengesError < Error
      def initialize(realm)
        super("No Authentication challenges for realm: #{realm.inspect}")
      end
    end

    def www_authenticate(realm: nil)
      challenges = Authenticator.challenges_for(realm: realm)
      raise NoChallengesError.new(realm) if challenges.empty?

      headers 'WWW-Authenticate' => challenges.map(&:to_s)
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
