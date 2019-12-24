# Write one more Authentication strategies here. Shaf supports Basic Auth and
# Digest Auth as well as non-standard authenticator that uses an api key token.
# You can also speficy your own by subclassing Shaf::Authenticator::Base.
#
# Examples:
#
# Shaf::Authenticator::BasicAuth.restricted realm: 'The good stuff' do |user, password|
#   return unless user && password
#   password_hash = Digest::SHA256.hexdigest(password)
#   User.where(username: user, password_hash: password_hash).first
# end
#
# Shaf::Authenticator::TokenAuth.restricted realm: 'restricted area' do |token, parameters|
#   return unless user && password
#   password_hash = Digest::SHA256.hexdigest(password)
#   User.where(username: user, password_hash: password_hash).first
#
#   digest = Shaf::CurrentUser.digest(auth_token) || return
#   User.where(auth_token_digest: digest).first
# end
