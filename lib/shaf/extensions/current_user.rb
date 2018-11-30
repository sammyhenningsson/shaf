require 'digest'

module Shaf
  module CurrentUser
    def self.registered(settings)
      return unless settings.respond_to?(:current_user) && settings.current_user

      settings.log.info 'Using Shaf::CurrentUser'
      settings.helpers Helpers
    end

    def self.digest(token)
      Digest::SHA256.hexdigest(token) if token
    end
  end

  module Helpers
    ERR_MSG = 'The default Shaf implementation of #current_user requires a ' \
      'User model with a column auth_token_digest'.freeze

    def auth_token
      header = settings.auth_token_header
      request.env[header]
    end

    def current_user
      return @current_user if defined?(@current_user)

      return unless check_user_model
      digest = Shaf::CurrentUser.digest(auth_token) || return
      @current_user = User.where(auth_token_digest: digest).first
    end

    def authenticated?
      !current_user.nil?
    end

    def authenticate!
      current_user || raise(Shaf::Errors::UnauthorizedError)
    end

    def check_user_model
      return true if defined?(User) && User.columns.include?(:auth_token_digest)
      log.warn ERR_MSG
      false
    end
  end
end
