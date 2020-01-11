module Shaf
  module Authenticator
    class DigestAuth < Base
      scheme 'Digest'

      param :realm
      param :domain, required: false
      # param :nonce
      # param :opaque
      # param :stale
      param :algorithm, default: 'MD5'
      param :qop, default: 'auth-int', values: ['auth', 'auth-int']
      param :charset, required: false, values: ['UTF-8']
      param :userhash, required: false, default: 'false', values: ['true', 'false']
    end
  end
end
