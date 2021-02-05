ENV['RACK_ENV'] = 'test'
require 'config/bootstrap'
require 'minitest/autorun'
require 'minitest/hooks'
require 'shaf/spec'

Shaf::Spec::Authenticator.restricted { |id:| User[id] }
