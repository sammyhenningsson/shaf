module Shaf
  module Authenticator
    class BasicAuth < Base
      scheme 'Basic'

      param :realm
      param :charset, required: false, values: ["UTF-8"]

      def self.credentials(authorization, _)
        return unless authorization

        decoded = String(authorization.unpack("m*").first)
        return {} if decoded.empty?

        user, password = decoded.split(/:/, 2)

        {
          user: user,
          password: password
        }
      end
    end
  end
end
