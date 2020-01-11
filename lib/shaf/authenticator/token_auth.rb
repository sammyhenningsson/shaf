module Shaf
  module Authenticator
    # Note: this is not an IANA registered scheme!
    class TokenAuth < Base
      scheme 'Token'

      param :realm
      param :header, default: 'X-Auth-Token'
    end
  end
end
