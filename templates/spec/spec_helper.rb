ENV['RACK_ENV'] = 'test'
require 'config/bootstrap'
require 'minitest/autorun'
require 'minitest/hooks'
require 'shaf/spec'

realm = Shaf::Settings.default_authentication_realm
Shaf::Spec::Authenticator.restricted realm: realm do |id:|
  User[id]
end
