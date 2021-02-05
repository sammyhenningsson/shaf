module Shaf
  module Spec
    class Authenticator < Shaf::Authenticator::Base
      scheme 'Test'

      param :realm, required: false

      def self.credentials(authorization, _request)
        { id: authorization&.to_i }
      end
    end
  end
end
