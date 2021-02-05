# Write one more Authentication strategies here. Shaf only supports Basic Auth
# by default but additional authenticators may be written. See
# https://github.com/sammyhenningsson/shaf/blob/master/doc/AUTHENTICATION.md
# for more info.
#
# Examples:
#
# Shaf::Authenticator::BasicAuth.restricted realm: 'user' do |user:, password:|
#   return unless user && password
#   password_hash = Digest::SHA256.hexdigest(password)
#   User.where(username: user, password_hash: password_hash).first
# end
#
# Shaf::Authenticator::BasicAuth.restricted realm: 'admin' do |user:, password:|
#   return unless user && password
#   password_hash = Digest::SHA256.hexdigest(password)
#   User.where(username: user, password_hash: password_hash, admin: true).first
# end
