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

    class RealmChangedError < Error
      def initialize(from:, to:)
        super <<~ERR
          Realm was changed from "#{from}" to "#{to}". This is not allowed!
          Each request corresponds to a certain realm and cannot be changed.
          This is probably caused by a call to `current_user` using the
          default realm (from `Shaf::Settings.default_authentication_realm`)
          and then using `#authenticate realm: 'some_other_realm'
        ERR
      end
    end

    def www_authenticate(realm: Settings.default_authentication_realm)
      challenges = Authenticator.challenges_for(realm: realm)
      raise NoChallengesError.new(realm) if challenges.empty?

      headers 'WWW-Authenticate' => challenges.map(&:to_s)
    end

    def authenticate(realm: Settings.default_authentication_realm)
      if defined?(@current_realm) && @current_realm&.to_s != realm&.to_s
        raise RealmChangedError.new(from: @current_realm , to: realm)
      else
        @current_realm = realm
      end

      current_user.tap do |user|
        www_authenticate(realm: realm) unless user
      end
    end

    def authenticate!(realm: Settings.default_authentication_realm)
      user = authenticate(realm: realm)
      return user if user

      msg = +"Unauthorized action"
      msg << " (Realm: #{realm})" if realm
      raise Shaf::Errors::UnauthorizedError, msg
    end
    alias current_user! authenticate!

    def authenticated?
      !current_user.nil?
    end

    def current_user
      unless defined? @current_realm
        if Settings.key? :default_authentication_realm
          @current_realm = Settings.default_authentication_realm
        else
          Shaf.logger.info <<~MSG
            No realm has been provided!
            Authentication/authorization cannot be performed. Did you perhaps
            forget to configure a realm in
            `Settings.default_authentication_realm` or provide it when calling
            `#authenticate!` (or `#authenticate!`)
          MSG
          return
        end
      end

      @current_user ||= Authenticator.user(request.env, realm: @current_realm)
    end
  end
end
