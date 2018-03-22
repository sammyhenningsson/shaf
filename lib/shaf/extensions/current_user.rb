require 'digest'

module Shaf
  module CurrentUser
    def self.registered(app)
      return unless app.respond_to?(:current_user) && app.current_user

      app.log.info 'Using Shaf::CurrentUser'
      app.helpers Helpers
    end

    def lookup_user_with(&block)
      unless block_given? && block.respond_to?(:call)
        raise ArgumentError, '::lookup_user_with requires a block argument'
      end
      log.info 'Using custom current_user lookup'
      Helpers.lookup_proc = block
    end
  end

  module Helpers
    class << self
      attr_accessor :lookup_proc

      def user_lookup(token)
        return lookup_proc.call(token) if lookup_proc
        return unless token
        digest = Digest::SHA256.hexdigest(token)
        User.where(auth_token_digest: digest).first
      end
    end

    def current_user
      return @current_user if defined?(@current_user)
      header = settings.auth_token_header
      @current_user = Helpers.user_lookup(request.env[header])
    end

    def authenticated?
      !current_user.nil?
    end
  end
end
