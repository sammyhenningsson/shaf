module Shaf
  module Spec
    class Authenticator < Shaf::Authenticator::Base
      scheme 'Test'

      param :realm, required: false

      def self.credentials(authorization, _)
        authorization&.to_i
      end
    end
  end
end
