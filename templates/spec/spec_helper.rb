ENV['RACK_ENV'] = 'test'
require 'config/bootstrap'
require 'minitest/autorun'
require 'minitest/hooks'
require 'shaf/spec'
